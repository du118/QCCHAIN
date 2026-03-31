// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**
 * @title CodeContribution
 * @dev 代码贡献自动奖励合约
 * 
 * 奖励标准:
 * - 普通 PR 合并：50 QC/次
 * - 核心模块开发：200 QC/次
 * - 漏洞修复（中低危）：300 QC/次
 * - 高危漏洞 & 安全加固：500-2000 QC/次
 * 
 * 验证机制:
 * - 由授权管理员签名验证 PR 合并
 * - 防止重复奖励
 * - 支持批量发放
 */
contract CodeContribution is Ownable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    
    IERC20 public immutable token;
    
    // 奖励等级
    enum RewardLevel {
        NORMAL,      // 普通 PR：50 QC
        CORE,        // 核心模块：200 QC
        BUGFIX_LOW,  // 中低危漏洞：300 QC
        BUGFIX_HIGH  // 高危漏洞：500-2000 QC
    }
    
    // 奖励金额映射
    mapping(RewardLevel => uint256) public rewardAmounts;
    
    // 管理员地址（可签名验证 PR）
    mapping(address => bool) public administrators;
    
    // 已奖励的 PR 记录（PR ID => 是否已奖励）
    mapping(string => bool) public rewardedPRs;
    
    // 贡献者信息
    struct ContributorInfo {
        uint256 totalReward;      // 累计奖励
        uint256 prCount;          // PR 数量
        uint256 lastRewardTime;   // 上次奖励时间
        mapping(RewardLevel => uint256) levelCount;  // 各等级贡献次数
    }
    
    // 贡献者地址 => 贡献信息
    mapping(address => ContributorInfo) public contributors;
    
    // 所有贡献者列表
    address[] public contributorAddresses;
    
    // 事件
    event AdministratorAdded(address indexed admin);
    event AdministratorRemoved(address indexed admin);
    event RewardLevelUpdated(RewardLevel level, uint256 newAmount);
    event ContributionRewarded(
        address indexed contributor,
        string prId,
        RewardLevel level,
        uint256 amount,
        string description
    );
    event BatchRewardsDistributed(address[] contributors, uint256[] amounts);
    event RewardWithdrawn(address indexed contributor, uint256 amount);
    
    /**
     * @dev 构造函数
     * @param _tokenAddress QC 代币合约地址
     */
    constructor(address _tokenAddress) Ownable() {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
        
        // 初始化奖励金额
        rewardAmounts[RewardLevel.NORMAL] = 50 * 10**18;      // 50 QC
        rewardAmounts[RewardLevel.CORE] = 200 * 10**18;       // 200 QC
        rewardAmounts[RewardLevel.BUGFIX_LOW] = 300 * 10**18; // 300 QC
        rewardAmounts[RewardLevel.BUGFIX_HIGH] = 1000 * 10**18; // 1000 QC（平均）
    }
    
    /**
     * @dev 添加管理员
     */
    function addAdministrator(address _admin) external onlyOwner {
        require(_admin != address(0), "Invalid address");
        require(!administrators[_admin], "Already administrator");
        
        administrators[_admin] = true;
        emit AdministratorAdded(_admin);
    }
    
    /**
     * @dev 移除管理员
     */
    function removeAdministrator(address _admin) external onlyOwner {
        require(administrators[_admin], "Not administrator");
        
        administrators[_admin] = false;
        emit AdministratorRemoved(_admin);
    }
    
    /**
     * @dev 更新奖励金额
     */
    function updateRewardAmount(RewardLevel _level, uint256 _amount) external onlyOwner {
        rewardAmounts[_level] = _amount;
        emit RewardLevelUpdated(_level, _amount);
    }
    
    /**
     * @dev 验证签名并奖励贡献者
     * @param _contributor 贡献者地址
     * @param _prId PR 唯一标识（如 "github-du118-QCCHAIN-123"）
     * @param _level 奖励等级
     * @param _description 描述
     * @param _signature 管理员签名
     */
    function rewardContribution(
        address _contributor,
        string calldata _prId,
        RewardLevel _level,
        string calldata _description,
        bytes calldata _signature
    ) external {
        require(administrators[msg.sender], "Not authorized");
        require(!rewardedPRs[_prId], "PR already rewarded");
        require(_contributor != address(0), "Invalid contributor address");
        
        // 验证签名
        bytes32 messageHash = keccak256(abi.encodePacked(_contributor, _prId, _level));
        address signer = ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), _signature);
        require(administrators[signer], "Invalid signature");
        
        // 计算奖励金额
        uint256 amount = rewardAmounts[_level];
        require(amount > 0, "Reward amount is 0");
        
        // 标记为已奖励
        rewardedPRs[_prId] = true;
        
        // 更新贡献者信息
        ContributorInfo storage contributor = contributors[_contributor];
        if (contributor.totalReward == 0) {
            contributorAddresses.push(_contributor);
        }
        contributor.totalReward += amount;
        contributor.prCount += 1;
        contributor.lastRewardTime = block.timestamp;
        contributor.levelCount[_level] += 1;
        
        // 转账奖励
        token.safeTransfer(_contributor, amount);
        
        emit ContributionRewarded(_contributor, _prId, _level, amount, _description);
    }
    
    /**
     * @dev 批量发放奖励（管理员直接调用，无需签名）
     * @param _contributors 贡献者地址列表
     * @param _prIds PR ID 列表
     * @param _levels 奖励等级列表
     * @param _amounts 奖励金额列表
     * @param _descriptions 描述列表
     */
    function batchReward(
        address[] calldata _contributors,
        string[] calldata _prIds,
        RewardLevel[] calldata _levels,
        uint256[] calldata _amounts,
        string[] calldata _descriptions
    ) external onlyOwner {
        require(
            _contributors.length == _prIds.length &&
            _contributors.length == _levels.length &&
            _contributors.length == _amounts.length &&
            _contributors.length == _descriptions.length,
            "Arrays length mismatch"
        );
        
        uint256 totalAmount = 0;
        
        for (uint256 i = 0; i < _contributors.length; i++) {
            require(!rewardedPRs[_prIds[i]], "PR already rewarded");
            totalAmount += _amounts[i];
            
            // 标记为已奖励
            rewardedPRs[_prIds[i]] = true;
            
            // 更新贡献者信息
            ContributorInfo storage contributor = contributors[_contributors[i]];
            if (contributor.totalReward == 0) {
                contributorAddresses.push(_contributors[i]);
            }
            contributor.totalReward += _amounts[i];
            contributor.prCount += 1;
            contributor.lastRewardTime = block.timestamp;
            contributor.levelCount[_levels[i]] += 1;
            
            emit ContributionRewarded(
                _contributors[i],
                _prIds[i],
                _levels[i],
                _amounts[i],
                _descriptions[i]
            );
        }
        
        // 批量转账
        token.safeTransfer(msg.sender, totalAmount);
        
        emit BatchRewardsDistributed(_contributors, _amounts);
    }
    
    /**
     * @dev 获取贡献者信息
     */
    function getContributorInfo(address _contributor) external view returns (
        uint256 totalReward,
        uint256 prCount,
        uint256 lastRewardTime,
        uint256 normalCount,
        uint256 coreCount,
        uint256 bugfixLowCount,
        uint256 bugfixHighCount
    ) {
        ContributorInfo storage contributor = contributors[_contributor];
        return (
            contributor.totalReward,
            contributor.prCount,
            contributor.lastRewardTime,
            contributor.levelCount[RewardLevel.NORMAL],
            contributor.levelCount[RewardLevel.CORE],
            contributor.levelCount[RewardLevel.BUGFIX_LOW],
            contributor.levelCount[RewardLevel.BUGFIX_HIGH]
        );
    }
    
    /**
     * @dev 获取贡献者总数
     */
    function getContributorCount() external view returns (uint256) {
        return contributorAddresses.length;
    }
    
    /**
     * @dev 检查 PR 是否已奖励
     */
    function isPRRewarded(string calldata _prId) external view returns (bool) {
        return rewardedPRs[_prId];
    }
    
    /**
     * @dev 获取奖励金额
     */
    function getRewardAmount(RewardLevel _level) external view returns (uint256) {
        return rewardAmounts[_level];
    }
    
    /**
     * @dev 获取所有奖励等级
     */
    function getAllRewardLevels() external pure returns (RewardLevel[] memory) {
        RewardLevel[] memory levels = new RewardLevel[](4);
        levels[0] = RewardLevel.NORMAL;
        levels[1] = RewardLevel.CORE;
        levels[2] = RewardLevel.BUGFIX_LOW;
        levels[3] = RewardLevel.BUGFIX_HIGH;
        return levels;
    }
    
    /**
     * @dev 紧急情况下回收误转的代币
     */
    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(token), "Cannot recover native token");
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}
