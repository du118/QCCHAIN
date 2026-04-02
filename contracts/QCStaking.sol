// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title QCStaking - QC 质押挖矿合约
 * @dev 支持 3 种质押模式：
 * 1. 质押 QC 挖矿
 * 2. 质押 BNB 挖矿
 * 3. 质押 LP 代币挖矿
 * 
 * 所有奖励从项目方钱包支出，零抽成
 */
contract QCStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    
    IERC20 public immutable qcToken;
    
    // 质押池信息
    struct Pool {
        uint256 pid;
        IERC20 lpToken;           // LP 代币地址（QC/BNB/其他）
        uint256 allocPoint;       // 分配权重
        uint256 lastRewardTime;   // 上次奖励时间
        uint256 accRewardPerShare; // 累计每份额奖励
        uint256 totalStaked;      // 总质押量
        bool isActive;            // 是否激活
    }
    
    // 用户质押信息
    struct UserInfo {
        uint256 amount;           // 质押数量
        uint256 rewardDebt;       // 奖励债务
        uint256 pendingReward;    // 待领取奖励
        uint256 lastStakeTime;    // 上次质押时间
    }
    
    // 所有质押池
    Pool[] public pools;
    
    // 用户质押信息 [pid][user]
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    
    // 奖励参数
    uint256 public rewardPerSecond;     // 每秒奖励（QC）
    uint256 public totalAllocPoint;     // 总分配权重
    uint256 public startTime;           // 开始时间
    uint256 public endTime;             // 结束时间
    uint256 public totalRewardPool;     // 奖励池总量
    uint256 public distributedReward;   // 已分发奖励
    
    // 事件
    event PoolAdded(uint256 pid, IERC20 lpToken, uint256 allocPoint);
    event Stake(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardPaid(address indexed user, uint256 indexed pid, uint256 amount);
    event RewardRateUpdated(uint256 newRate);
    
    /**
     * @dev 构造函数
     * @param _qcToken QC 代币合约地址
     */
    constructor(address _qcToken) Ownable() {
        require(_qcToken != address(0), "Invalid QC token address");
        qcToken = IERC20(_qcToken);
    }
    
    /**
     * @dev 添加质押池
     * @param _lpToken LP 代币地址
     * @param _allocPoint 分配权重
     * @param _isActive 是否激活
     */
    function addPool(IERC20 _lpToken, uint256 _allocPoint, bool _isActive) external onlyOwner {
        require(address(_lpToken) != address(0), "Invalid LP token");
        
        pools.push(Pool({
            pid: pools.length,
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardTime: startTime == 0 ? block.timestamp : startTime,
            accRewardPerShare: 0,
            totalStaked: 0,
            isActive: _isActive
        }));
        
        totalAllocPoint += _allocPoint;
        
        emit PoolAdded(pools.length - 1, _lpToken, _allocPoint);
    }
    
    /**
     * @dev 设置奖励速率
     * @param _rewardPerSecond 每秒奖励数量
     */
    function setRewardRate(uint256 _rewardPerSecond) external onlyOwner {
        rewardPerSecond = _rewardPerSecond;
        emit RewardRateUpdated(_rewardPerSecond);
    }
    
    /**
     * @dev 设置奖励时间范围
     * @param _startTime 开始时间
     * @param _endTime 结束时间
     */
    function setRewardTime(uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_endTime > _startTime, "Invalid time range");
        startTime = _startTime;
        endTime = _endTime;
    }
    
    /**
     * @dev 设置奖励池总量
     * @param _totalReward 总奖励数量
     */
    function setRewardPool(uint256 _totalReward) external onlyOwner {
        totalRewardPool = _totalReward;
    }
    
    /**
     * @dev 更新质押池分配权重
     * @param _pid 质押池 ID
     * @param _allocPoint 新权重
     */
    function updatePool(uint256 _pid, uint256 _allocPoint) external onlyOwner {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        
        totalAllocPoint = totalAllocPoint - pool.allocPoint + _allocPoint;
        pool.allocPoint = _allocPoint;
    }
    
    /**
     * @dev 更新质押池奖励
     */
    function updatePool(uint256 _pid) public {
        Pool storage pool = pools[_pid];
        
        if (block.timestamp <= pool.lastRewardTime) {
            return;
        }
        
        if (block.timestamp > endTime) {
            pool.lastRewardTime = endTime;
            return;
        }
        
        if (totalAllocPoint == 0 || pool.allocPoint == 0) {
            pool.lastRewardTime = block.timestamp;
            return;
        }
        
        uint256 timePassed = block.timestamp - pool.lastRewardTime;
        uint256 reward = (timePassed * rewardPerSecond * pool.allocPoint) / totalAllocPoint;
        
        // 检查奖励池余额
        uint256 remainingReward = totalRewardPool - distributedReward;
        if (reward > remainingReward) {
            reward = remainingReward;
        }
        
        if (pool.totalStaked > 0) {
            pool.accRewardPerShare += (reward * 1e18) / pool.totalStaked;
        }
        
        pool.lastRewardTime = block.timestamp;
        distributedReward += reward;
    }
    
    /**
     * @dev 质押代币
     * @param _pid 质押池 ID
     * @param _amount 质押数量
     */
    function stake(uint256 _pid, uint256 _amount) external nonReentrant {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        updatePool(_pid);
        
        if (user.amount > 0) {
            uint256 pending = (user.amount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);
                emit RewardPaid(msg.sender, _pid, pending);
            }
        }
        
        if (_amount > 0) {
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.amount += _amount;
            pool.totalStaked += _amount;
            user.lastStakeTime = block.timestamp;
        }
        
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e18;
        
        emit Stake(msg.sender, _pid, _amount);
    }
    
    /**
     * @dev 提取质押
     * @param _pid 质押池 ID
     * @param _amount 提取数量
     */
    function withdraw(uint256 _pid, uint256 _amount) external nonReentrant {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        require(user.amount >= _amount, "Insufficient staked amount");
        
        updatePool(_pid);
        
        uint256 pending = (user.amount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;
        if (pending > 0) {
            safeRewardTransfer(msg.sender, pending);
            emit RewardPaid(msg.sender, _pid, pending);
        }
        
        if (_amount > 0) {
            user.amount -= _amount;
            pool.totalStaked -= _amount;
            pool.lpToken.safeTransfer(msg.sender, _amount);
        }
        
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e18;
        
        emit Withdraw(msg.sender, _pid, _amount);
    }
    
    /**
     * @dev 提取全部并领取奖励
     * @param _pid 质押池 ID
     */
    function exit(uint256 _pid) external nonReentrant {
        uint256 amount = userInfo[_pid][msg.sender].amount;
        if (amount > 0) {
            // 直接执行提取逻辑
            Pool storage pool = pools[_pid];
            UserInfo storage user = userInfo[_pid][msg.sender];
            
            updatePool(_pid);
            
            uint256 pending = (user.amount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;
            if (pending > 0) {
                safeRewardTransfer(msg.sender, pending);
                emit RewardPaid(msg.sender, _pid, pending);
            }
            
            user.amount = 0;
            pool.totalStaked -= amount;
            pool.lpToken.safeTransfer(msg.sender, amount);
            user.rewardDebt = 0;
            
            emit Withdraw(msg.sender, _pid, amount);
        }
    }
    
    /**
     * @dev 领取奖励
     * @param _pid 质押池 ID
     */
    function claimReward(uint256 _pid) external nonReentrant {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        
        updatePool(_pid);
        
        uint256 pending = (user.amount * pool.accRewardPerShare) / 1e18 - user.rewardDebt;
        require(pending > 0, "No reward to claim");
        
        safeRewardTransfer(msg.sender, pending);
        user.rewardDebt = (user.amount * pool.accRewardPerShare) / 1e18;
        
        emit RewardPaid(msg.sender, _pid, pending);
    }
    
    /**
     * @dev 查询待领取奖励
     * @param _pid 质押池 ID
     * @param _user 用户地址
     */
    function pendingReward(uint256 _pid, address _user) public view returns (uint256) {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        
        uint256 accRewardPerShare = pool.accRewardPerShare;
        
        if (block.timestamp > pool.lastRewardTime && pool.totalStaked > 0 && totalAllocPoint > 0) {
            uint256 timePassed = block.timestamp - pool.lastRewardTime;
            uint256 reward = (timePassed * rewardPerSecond * pool.allocPoint) / totalAllocPoint;
            
            uint256 remainingReward = totalRewardPool - distributedReward;
            if (reward > remainingReward) {
                reward = remainingReward;
            }
            
            accRewardPerShare += (reward * 1e18) / pool.totalStaked;
        }
        
        return (user.amount * accRewardPerShare) / 1e18 - user.rewardDebt;
    }
    
    /**
     * @dev 获取质押池数量
     */
    function poolLength() external view returns (uint256) {
        return pools.length;
    }
    
    /**
     * @dev 获取质押池信息
     */
    function getPoolInfo(uint256 _pid) external view returns (
        IERC20 lpToken,
        uint256 allocPoint,
        uint256 lastRewardTime,
        uint256 accRewardPerShare,
        uint256 totalStaked,
        bool isActive
    ) {
        require(_pid < pools.length, "Pool not exist");
        Pool storage pool = pools[_pid];
        return (
            pool.lpToken,
            pool.allocPoint,
            pool.lastRewardTime,
            pool.accRewardPerShare,
            pool.totalStaked,
            pool.isActive
        );
    }
    
    /**
     * @dev 获取用户质押信息
     */
    function getUserInfo(uint256 _pid, address _user) external view returns (
        uint256 amount,
        uint256 rewardDebt,
        uint256 pending,
        uint256 lastStakeTime
    ) {
        require(_pid < pools.length, "Pool not exist");
        UserInfo storage user = userInfo[_pid][_user];
        return (
            user.amount,
            user.rewardDebt,
            pendingReward(_pid, _user),
            user.lastStakeTime
        );
    }
    
    /**
     * @dev 安全转账奖励
     */
    function safeRewardTransfer(address _to, uint256 _amount) internal {
        uint256 balance = qcToken.balanceOf(address(this));
        if (_amount > balance) {
            _amount = balance;
        }
        if (_amount > 0) {
            qcToken.safeTransfer(_to, _amount);
        }
    }
    
    /**
     * @dev 紧急提取（仅限 owner）
     */
    function emergencyWithdraw(uint256 _pid) external onlyOwner {
        Pool storage pool = pools[_pid];
        pool.lpToken.safeTransfer(msg.sender, pool.totalStaked);
        pool.totalStaked = 0;
    }
    
    /**
     * @dev 提取剩余奖励（仅限 owner）
     */
    function withdrawRemainingReward(address _to) external onlyOwner {
        uint256 balance = qcToken.balanceOf(address(this));
        if (balance > 0) {
            qcToken.safeTransfer(_to, balance);
        }
    }
}
