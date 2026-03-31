// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title QCToken
 * @dev QC Chain 原生代币合约
 * 
 * 核心特性:
 * - 总供应量固定 1800 万枚，永不增发
 * - 支持代币燃烧
 * - 支持 EIP-2612 Permit
 * - 紧急暂停功能
 * -  Ownable 权限控制
 */
contract QCToken is ERC20, ERC20Burnable, ERC20Permit, Ownable, Pausable {
    
    // 总供应量：1800 万 QC（18 位小数）
    uint256 private constant MAX_SUPPLY = 18_000_000 * 10**18;
    
    // 代币分配地址
    address public founderAddress;      // 创始人地址（35%）
    address public teamAddress;         // 核心团队地址（15%）
    address public miningAddress;       // 挖矿奖励地址（30%）
    address public ecosystemAddress;    // 生态建设地址（5%）
    address public marketingAddress;    // 市场运营地址（5%）
    address public communityAddress;    // 社区激励地址（5%）
    address public maintenanceAddress;  // 代码维护地址（5%）
    
    // 代币分配数量
    uint256 public founderAmount;       // 6,300,000 QC
    uint256 public teamAmount;          // 2,700,000 QC
    uint256 public miningAmount;        // 5,400,000 QC
    uint256 public ecosystemAmount;     // 900,000 QC
    uint256 public marketingAmount;     // 900,000 QC
    uint256 public communityAmount;     // 900,000 QC
    uint256 public maintenanceAmount;   // 900,000 QC
    
    // 分配状态
    bool public distributionCompleted = false;
    
    // 事件
    event TokenDistribution(address indexed to, uint256 amount, string category);
    event DistributionCompleted();
    
    /**
     * @dev 构造函数
     * @param _founderAddress 创始人地址
     * @param _teamAddress 核心团队地址
     * @param _miningAddress 挖矿奖励地址
     * @param _ecosystemAddress 生态建设地址
     * @param _marketingAddress 市场运营地址
     * @param _communityAddress 社区激励地址
     * @param _maintenanceAddress 代码维护地址
     */
    constructor(
        address _founderAddress,
        address _teamAddress,
        address _miningAddress,
        address _ecosystemAddress,
        address _marketingAddress,
        address _communityAddress,
        address _maintenanceAddress
    ) ERC20("Quantum Coin", "QC") ERC20Permit("Quantum Coin") Ownable() {
        require(_founderAddress != address(0), "Invalid founder address");
        require(_teamAddress != address(0), "Invalid team address");
        require(_miningAddress != address(0), "Invalid mining address");
        require(_ecosystemAddress != address(0), "Invalid ecosystem address");
        require(_marketingAddress != address(0), "Invalid marketing address");
        require(_communityAddress != address(0), "Invalid community address");
        require(_maintenanceAddress != address(0), "Invalid maintenance address");
        
        founderAddress = _founderAddress;
        teamAddress = _teamAddress;
        miningAddress = _miningAddress;
        ecosystemAddress = _ecosystemAddress;
        marketingAddress = _marketingAddress;
        communityAddress = _communityAddress;
        maintenanceAddress = _maintenanceAddress;
        
        // 计算各部分数量
        founderAmount = MAX_SUPPLY * 35 / 100;        // 6,300,000 QC
        teamAmount = MAX_SUPPLY * 15 / 100;           // 2,700,000 QC
        miningAmount = MAX_SUPPLY * 30 / 100;         // 5,400,000 QC
        ecosystemAmount = MAX_SUPPLY * 5 / 100;       // 900,000 QC
        marketingAmount = MAX_SUPPLY * 5 / 100;       // 900,000 QC
        communityAmount = MAX_SUPPLY * 5 / 100;       // 900,000 QC
        maintenanceAmount = MAX_SUPPLY * 5 / 100;     // 900,000 QC
        
        // 铸造全部代币到合约地址（由合约控制分配）
        _mint(address(this), MAX_SUPPLY);
        
        emit TokenDistribution(address(this), MAX_SUPPLY, "Initial Mint");
    }
    
    /**
     * @dev 执行代币分配（只能调用一次）
     * 将所有代币分配到预设地址
     */
    function executeDistribution() external onlyOwner {
        require(!distributionCompleted, "Distribution already completed");
        
        // 转账给各分配地址
        _transfer(address(this), founderAddress, founderAmount);
        emit TokenDistribution(founderAddress, founderAmount, "Founder");
        
        _transfer(address(this), teamAddress, teamAmount);
        emit TokenDistribution(teamAddress, teamAmount, "Team");
        
        _transfer(address(this), miningAddress, miningAmount);
        emit TokenDistribution(miningAddress, miningAmount, "Mining");
        
        _transfer(address(this), ecosystemAddress, ecosystemAmount);
        emit TokenDistribution(ecosystemAddress, ecosystemAmount, "Ecosystem");
        
        _transfer(address(this), marketingAddress, marketingAmount);
        emit TokenDistribution(marketingAddress, marketingAmount, "Marketing");
        
        _transfer(address(this), communityAddress, communityAmount);
        emit TokenDistribution(communityAddress, communityAmount, "Community");
        
        _transfer(address(this), maintenanceAddress, maintenanceAmount);
        emit TokenDistribution(maintenanceAddress, maintenanceAmount, "Maintenance");
        
        distributionCompleted = true;
        emit DistributionCompleted();
    }
    
    /**
     * @dev 覆盖转账函数，添加暂停检查
     */
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }
    
    /**
     * @dev 覆盖授权转账函数，添加暂停检查
     */
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }
    
    /**
     * @dev 暂停代币转账（紧急情况）
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev 恢复代币转账
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev 获取最大供应量
     */
    function maxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }
    
    /**
     * @dev 获取代币分配信息
     */
    function getDistributionInfo() external view returns (
        uint256 _founderAmount,
        uint256 _teamAmount,
        uint256 _miningAmount,
        uint256 _ecosystemAmount,
        uint256 _marketingAmount,
        uint256 _communityAmount,
        uint256 _maintenanceAmount,
        bool _distributionCompleted
    ) {
        return (
            founderAmount,
            teamAmount,
            miningAmount,
            ecosystemAmount,
            marketingAmount,
            communityAmount,
            maintenanceAmount,
            distributionCompleted
        );
    }
    
    /**
     * @dev 紧急情况下回收误转的代币
     * @param tokenAddress 代币合约地址
     * @param to 接收地址
     * @param amount 回收数量
     */
    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(this), "Cannot recover native token");
        IERC20(tokenAddress).transfer(to, amount);
    }
}
