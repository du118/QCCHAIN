// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MiningReward
 * @dev 挖矿奖励合约 - 实现比特币式减半机制
 * 
 * 核心规则:
 * - 初始奖励：2 QC/区块
 * - 减半周期：210,000 区块
 * - 总奖励上限：5,400,000 QC
 * - 分配：出块节点 70%，稳定节点 30%
 */
contract MiningReward is Ownable {
    using SafeERC20 for IERC20;
    
    IERC20 public immutable token;
    
    // 挖矿参数
    uint256 public constant INITIAL_REWARD = 2 * 10**18;  // 初始奖励 2 QC（18 位小数）
    uint256 public constant HALVING_INTERVAL = 210_000;   // 减半周期（区块数）
    uint256 public constant MAX_MINING_REWARD = 5_400_000 * 10**18;  // 总奖励上限 540 万 QC
    
    // 挖矿状态
    uint256 public startBlockNumber;      // 开始区块高度
    uint256 public totalMined;            // 已挖出总量
    uint256 public currentBlockReward;    // 当前区块奖励
    uint256 public halvingCount;          // 已减半次数
    
    // 节点信息
    struct NodeInfo {
        bool exists;
        uint256 stakeAmount;      // 质押数量
        uint256 blocksMined;      // 挖出区块数
        uint256 totalReward;      // 累计奖励
        uint256 lastClaimBlock;   // 上次领取奖励的区块
        bool isStableNode;        // 是否稳定节点
        uint256 registerTime;     // 注册时间
    }
    
    // 节点地址 => 节点信息
    mapping(address => NodeInfo) public nodes;
    
    // 所有节点列表
    address[] public nodeAddresses;
    
    // 区块高度 => 出块节点
    mapping(uint256 => address) public blockMiners;
    
    // 是否已启动挖矿
    bool public miningStarted = false;
    
    // 事件
    event MiningStarted(uint256 startBlock, uint256 initialReward);
    event BlockMined(address indexed miner, uint256 blockNumber, uint256 reward);
    event RewardClaimed(address indexed node, uint256 amount);
    event NodeRegistered(address indexed node, bool isStableNode, uint256 stakeAmount);
    event HalvingOccurred(uint256 halvingCount, uint256 newReward);
    event MiningStopped(string reason);
    
    /**
     * @dev 构造函数
     * @param _tokenAddress QC 代币合约地址
     */
    constructor(address _tokenAddress) Ownable() {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
        currentBlockReward = INITIAL_REWARD;
    }
    
    /**
     * @dev 启动挖矿（只能调用一次）
     * @param _startBlock 开始区块高度
     */
    function startMining(uint256 _startBlock) external onlyOwner {
        require(!miningStarted, "Mining already started");
        require(_startBlock > block.number, "Start block must be in the future");
        
        startBlockNumber = _startBlock;
        miningStarted = true;
        
        emit MiningStarted(_startBlock, INITIAL_REWARD);
    }
    
    /**
     * @dev 注册节点
     * @param _isStableNode 是否稳定节点（影响奖励分配）
     * @param _stakeAmount 质押数量
     */
    function registerNode(bool _isStableNode, uint256 _stakeAmount) external {
        require(!nodes[msg.sender].exists, "Node already registered");
        require(_stakeAmount > 0, "Stake amount must be greater than 0");
        
        // 转账质押代币
        token.safeTransferFrom(msg.sender, address(this), _stakeAmount);
        
        nodes[msg.sender] = NodeInfo({
            exists: true,
            stakeAmount: _stakeAmount,
            blocksMined: 0,
            totalReward: 0,
            lastClaimBlock: startBlockNumber,
            isStableNode: _isStableNode,
            registerTime: block.timestamp
        });
        
        nodeAddresses.push(msg.sender);
        
        emit NodeRegistered(msg.sender, _isStableNode, _stakeAmount);
    }
    
    /**
     * @dev 记录区块产出（由共识层调用）
     * @param _miner 出块节点地址
     * @param _blockNumber 区块高度
     */
    function recordBlockMined(address _miner, uint256 _blockNumber) external onlyOwner {
        require(miningStarted, "Mining not started");
        require(_blockNumber >= startBlockNumber, "Block number too early");
        require(nodes[_miner].exists, "Miner not registered");
        require(blockMiners[_blockNumber] == address(0), "Block already recorded");
        
        // 检查是否达到总奖励上限
        if (totalMined >= MAX_MINING_REWARD) {
            emit MiningStopped("Max mining reward reached");
            return;
        }
        
        // 计算当前区块奖励
        uint256 reward = calculateBlockReward(_blockNumber);
        
        // 更新状态
        blockMiners[_blockNumber] = _miner;
        nodes[_miner].blocksMined += 1;
        nodes[_miner].totalReward += reward;
        totalMined += reward;
        
        emit BlockMined(_miner, _blockNumber, reward);
    }
    
    /**
     * @dev 计算区块奖励（含减半机制）
     * @param _blockNumber 区块高度
     * @return 区块奖励
     */
    function calculateBlockReward(uint256 _blockNumber) public view returns (uint256) {
        if (_blockNumber < startBlockNumber) {
            return 0;
        }
        
        uint256 blocksSinceStart = _blockNumber - startBlockNumber;
        uint256 halvings = blocksSinceStart / HALVING_INTERVAL;
        
        // 防止溢出，奖励最小为 0
        if (halvings >= 64) {
            return 0;
        }
        
        uint256 reward = INITIAL_REWARD >> halvings;
        
        // 检查是否超过总奖励上限
        uint256 remainingReward = MAX_MINING_REWARD - totalMined;
        if (reward > remainingReward) {
            reward = remainingReward;
        }
        
        return reward;
    }
    
    /**
     * @dev 获取当前应分配的奖励（出块节点 70%，稳定节点池 30%）
     * @param _blockReward 区块总奖励
     * @return minerReward 出块节点奖励
     * @return stablePoolReward 稳定节点池奖励
     */
    function getRewardDistribution(uint256 _blockReward) public pure returns (
        uint256 minerReward,
        uint256 stablePoolReward
    ) {
        minerReward = (_blockReward * 70) / 100;      // 70% 给出块节点
        stablePoolReward = (_blockReward * 30) / 100; // 30% 给稳定节点池
    }
    
    /**
     * @dev 领取挖矿奖励
     */
    function claimReward() external {
        require(nodes[msg.sender].exists, "Node not registered");
        
        uint256 reward = getClaimableReward(msg.sender);
        require(reward > 0, "No reward to claim");
        
        nodes[msg.sender].totalReward -= reward;
        
        token.safeTransfer(msg.sender, reward);
        
        emit RewardClaimed(msg.sender, reward);
    }
    
    /**
     * @dev 获取可领取的奖励数量
     */
    function getClaimableReward(address _node) public view returns (uint256) {
        if (!nodes[_node].exists) {
            return 0;
        }
        
        // 简单实现：返回节点累计奖励
        // 实际部署时需要根据链上区块数据计算
        return nodes[_node].totalReward;
    }
    
    /**
     * @dev 获取当前减半次数
     */
    function getCurrentHalvingCount() external view returns (uint256) {
        if (!miningStarted || block.number < startBlockNumber) {
            return 0;
        }
        
        return (block.number - startBlockNumber) / HALVING_INTERVAL;
    }
    
    /**
     * @dev 获取距离下次减半的区块数
     */
    function getBlocksUntilNextHalving() external view returns (uint256) {
        if (!miningStarted || block.number < startBlockNumber) {
            return HALVING_INTERVAL;
        }
        
        uint256 blocksSinceStart = block.number - startBlockNumber;
        uint256 blocksIntoCurrentEpoch = blocksSinceStart % HALVING_INTERVAL;
        
        return HALVING_INTERVAL - blocksIntoCurrentEpoch;
    }
    
    /**
     * @dev 获取节点信息
     */
    function getNodeInfo(address _node) external view returns (
        bool exists,
        uint256 stakeAmount,
        uint256 blocksMined,
        uint256 totalReward,
        uint256 lastClaimBlock,
        bool isStableNode,
        uint256 registerTime
    ) {
        NodeInfo storage node = nodes[_node];
        return (
            node.exists,
            node.stakeAmount,
            node.blocksMined,
            node.totalReward,
            node.lastClaimBlock,
            node.isStableNode,
            node.registerTime
        );
    }
    
    /**
     * @dev 获取节点总数
     */
    function getNodeCount() external view returns (uint256) {
        return nodeAddresses.length;
    }
    
    /**
     * @dev 获取挖矿进度
     */
    function getMiningProgress() external view returns (
        uint256 totalMined,
        uint256 maxReward,
        uint256 percentage,
        uint256 currentReward,
        uint256 halvingCount
    ) {
        return (
            totalMined,
            MAX_MINING_REWARD,
            (totalMined * 10000) / MAX_MINING_REWARD,  // 百分比（basis points）
            currentBlockReward,
            halvingCount
        );
    }
    
    /**
     * @dev 紧急情况下停止挖矿
     */
    function emergencyStop(string calldata _reason) external onlyOwner {
        emit MiningStopped(_reason);
    }
    
    /**
     * @dev 紧急情况下回收误转的代币
     */
    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(token), "Cannot recover native token");
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}
