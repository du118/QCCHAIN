// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VestingSchedule
 * @dev 代币线性解锁合约
 * 
 * 支持两种解锁方案:
 * 1. 创始人解锁：36 个月线性解锁（主网上线解锁 20%）
 * 2. 团队解锁：18 个月线性解锁（主网上线解锁 20%）
 */
contract VestingSchedule is Ownable {
    using SafeERC20 for IERC20;
    
    struct VestingInfo {
        address beneficiary;      // 受益人地址
        uint256 totalAmount;      // 总分配数量
        uint256 releasedAmount;   // 已释放数量
        uint256 startTime;        // 开始时间（主网上线时间）
        uint256 duration;         // 解锁周期（秒）
        uint256 initialUnlock;    // 初始解锁比例（20% = 2000，即 20.00%）
        bool isFounder;           // 是否创始人（36 个月 vs 18 个月）
        bool claimed;             // 是否已领取初始解锁
    }
    
    IERC20 public immutable token;
    
    // 受益人 => 解锁信息
    mapping(address => VestingInfo) public vestingSchedules;
    
    // 所有受益人列表
    address[] public beneficiaries;
    
    // 事件
    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 totalAmount,
        uint256 startTime,
        uint256 duration,
        uint256 initialUnlock,
        bool isFounder
    );
    event TokensReleased(address indexed beneficiary, uint256 amount);
    event InitialUnlockClaimed(address indexed beneficiary, uint256 amount);
    event VestingDurationUpdated(address indexed beneficiary, uint256 newDuration);
    
    /**
     * @dev 构造函数
     * @param _tokenAddress QC 代币合约地址
     */
    constructor(address _tokenAddress) Ownable() {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }
    
    /**
     * @dev 创建解锁计划
     * @param _beneficiary 受益人地址
     * @param _totalAmount 总分配数量
     * @param _startTime 开始时间（主网上线时间）
     * @param _duration 解锁周期（秒）
     * @param _initialUnlock 初始解锁比例（basis points，2000 = 20%）
     * @param _isFounder 是否创始人
     */
    function createVestingSchedule(
        address _beneficiary,
        uint256 _totalAmount,
        uint256 _startTime,
        uint256 _duration,
        uint256 _initialUnlock,
        bool _isFounder
    ) public onlyOwner {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_totalAmount > 0, "Amount must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");
        require(_initialUnlock <= 10000, "Initial unlock cannot exceed 100%");
        require(vestingSchedules[_beneficiary].totalAmount == 0, "Vesting schedule already exists");
        
        vestingSchedules[_beneficiary] = VestingInfo({
            beneficiary: _beneficiary,
            totalAmount: _totalAmount,
            releasedAmount: 0,
            startTime: _startTime,
            duration: _duration,
            initialUnlock: _initialUnlock,
            isFounder: _isFounder,
            claimed: false
        });
        
        beneficiaries.push(_beneficiary);
        
        emit VestingScheduleCreated(
            _beneficiary,
            _totalAmount,
            _startTime,
            _duration,
            _initialUnlock,
            _isFounder
        );
    }
    
    /**
     * @dev 批量创建解锁计划
     * @param _beneficiaries 受益人地址列表
     * @param _amounts 分配数量列表
     * @param _startTime 开始时间
     * @param _duration 解锁周期
     * @param _initialUnlock 初始解锁比例
     * @param _isFounder 是否创始人
     */
    function createBatchVestingSchedules(
        address[] calldata _beneficiaries,
        uint256[] calldata _amounts,
        uint256 _startTime,
        uint256 _duration,
        uint256 _initialUnlock,
        bool _isFounder
    ) external onlyOwner {
        require(_beneficiaries.length == _amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            createVestingSchedule(
                _beneficiaries[i],
                _amounts[i],
                _startTime,
                _duration,
                _initialUnlock,
                _isFounder
            );
        }
    }
    
    /**
     * @dev 领取初始解锁部分（主网上线时）
     */
    function claimInitialUnlock() external {
        VestingInfo storage vesting = vestingSchedules[msg.sender];
        require(vesting.totalAmount > 0, "No vesting schedule found");
        require(!vesting.claimed, "Initial unlock already claimed");
        require(block.timestamp >= vesting.startTime, "Not started yet");
        
        uint256 initialAmount = (vesting.totalAmount * vesting.initialUnlock) / 10000;
        require(initialAmount > 0, "Initial unlock amount is 0");
        
        vesting.releasedAmount += initialAmount;
        vesting.claimed = true;
        
        token.safeTransfer(msg.sender, initialAmount);
        
        emit InitialUnlockClaimed(msg.sender, initialAmount);
    }
    
    /**
     * @dev 计算当前可释放的代币数量（线性解锁部分）
     * @param _beneficiary 受益人地址
     * @return 可释放数量
     */
    function calculatereleasableAmount(address _beneficiary) public view returns (uint256) {
        VestingInfo storage vesting = vestingSchedules[_beneficiary];
        
        if (vesting.totalAmount == 0) {
            return 0;
        }
        
        // 如果还没领取初始解锁，先计算初始解锁
        if (!vesting.claimed) {
            return 0;
        }
        
        // 线性解锁部分 = 总量 * (100% - 初始解锁%)
        uint256 linearAmount = (vesting.totalAmount * (10000 - vesting.initialUnlock)) / 10000;
        
        // 如果还没到开始时间
        if (block.timestamp < vesting.startTime) {
            return 0;
        }
        
        // 如果已经解锁完成
        if (block.timestamp >= vesting.startTime + vesting.duration) {
            uint256 totalReleasable = vesting.totalAmount;
            return totalReleasable > vesting.releasedAmount 
                ? totalReleasable - vesting.releasedAmount 
                : 0;
        }
        
        // 线性解锁计算
        uint256 timePassed = block.timestamp - vesting.startTime;
        uint256 totalReleasable = (linearAmount * timePassed) / vesting.duration;
        totalReleasable += (vesting.totalAmount * vesting.initialUnlock) / 10000; // 加上初始解锁
        
        return totalReleasable > vesting.releasedAmount 
            ? totalReleasable - vesting.releasedAmount 
            : 0;
    }
    
    /**
     * @dev 释放可领取的代币
     */
    function release() external {
        uint256 amount = calculatereleasableAmount(msg.sender);
        require(amount > 0, "No tokens to release");
        
        VestingInfo storage vesting = vestingSchedules[msg.sender];
        vesting.releasedAmount += amount;
        
        token.safeTransfer(msg.sender, amount);
        
        emit TokensReleased(msg.sender, amount);
    }
    
    /**
     * @dev 获取解锁信息
     */
    function getVestingInfo(address _beneficiary) external view returns (
        address beneficiary,
        uint256 totalAmount,
        uint256 releasedAmount,
        uint256 releasableAmount,
        uint256 startTime,
        uint256 duration,
        uint256 initialUnlock,
        bool isFounder,
        bool claimed
    ) {
        VestingInfo storage vesting = vestingSchedules[_beneficiary];
        return (
            vesting.beneficiary,
            vesting.totalAmount,
            vesting.releasedAmount,
            calculatereleasableAmount(_beneficiary),
            vesting.startTime,
            vesting.duration,
            vesting.initialUnlock,
            vesting.isFounder,
            vesting.claimed
        );
    }
    
    /**
     * @dev 获取所有受益人数量
     */
    function getBeneficiariesCount() external view returns (uint256) {
        return beneficiaries.length;
    }
    
    /**
     * @dev 获取所有受益人列表（分页）
     * @param _offset 偏移量
     * @param _limit 限制数量
     */
    function getBeneficiaries(uint256 _offset, uint256 _limit) external view returns (address[] memory) {
        require(_offset < beneficiaries.length, "Offset out of bounds");
        
        uint256 end = _offset + _limit;
        if (end > beneficiaries.length) {
            end = beneficiaries.length;
        }
        
        address[] memory result = new address[](end - _offset);
        for (uint256 i = _offset; i < end; i++) {
            result[i - _offset] = beneficiaries[i];
        }
        
        return result;
    }
    
    /**
     * @dev 紧急情况下更新解锁周期（仅限 owner）
     */
    function updateVestingDuration(address _beneficiary, uint256 _newDuration) external onlyOwner {
        require(vestingSchedules[_beneficiary].totalAmount > 0, "No vesting schedule found");
        vestingSchedules[_beneficiary].duration = _newDuration;
        emit VestingDurationUpdated(_beneficiary, _newDuration);
    }
    
    /**
     * @dev 紧急情况下回收误转的代币
     */
    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(token), "Cannot recover native token");
        IERC20(tokenAddress).safeTransfer(to, amount);
    }
}
