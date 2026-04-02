// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)
interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/utils/SafeERC20.sol)
library SafeERC20 {
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        (bool success, bytes memory returndata) = address(token).staticcall(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Context.sol)
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)
abstract contract Ownable {
    address private _owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() {
        _transferOwnership(_msgSender());
    }
    
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/ERC20.sol)
contract ERC20 is Context, IERC20, IERC20Permit {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    
    function name() public view virtual returns (string memory) {
        return _name;
    }
    
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address) public view virtual returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
    }
    
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
    }
    
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
    }
    
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        
        _allowances[owner][spender] = amount;
    }
    
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/ERC20Burnable.sol)
abstract contract ERC20Burnable is ERC20 {
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }
    
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (security/Pausable.sol)
abstract contract Pausable {
    bool private _paused;
    
    event Paused(address account);
    event Unpaused(address account);
    
    constructor() {
        _paused = false;
    }
    
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    
    modifier whenPaused() {
        _requirePaused();
        _;
    }
    
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }
    
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }
    
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// ==================== QC Token Contract ====================

contract QCToken is ERC20, ERC20Burnable, Ownable, Pausable {
    
    uint256 private constant MAX_SUPPLY = 18_000_000 * 10**18;
    
    address public founderAddress;
    address public teamAddress;
    address public miningAddress;
    address public ecosystemAddress;
    address public marketingAddress;
    address public communityAddress;
    address public maintenanceAddress;
    
    uint256 public founderAmount;
    uint256 public teamAmount;
    uint256 public miningAmount;
    uint256 public ecosystemAmount;
    uint256 public marketingAmount;
    uint256 public communityAmount;
    uint256 public maintenanceAmount;
    
    bool public distributionCompleted = false;
    
    event TokenDistribution(address indexed to, uint256 amount, string category);
    event DistributionCompleted();
    
    constructor(
        address _founderAddress,
        address _teamAddress,
        address _miningAddress,
        address _ecosystemAddress,
        address _marketingAddress,
        address _communityAddress,
        address _maintenanceAddress
    ) ERC20("Quantum Coin", "QC") {
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
        
        founderAmount = MAX_SUPPLY * 35 / 100;
        teamAmount = MAX_SUPPLY * 15 / 100;
        miningAmount = MAX_SUPPLY * 30 / 100;
        ecosystemAmount = MAX_SUPPLY * 5 / 100;
        marketingAmount = MAX_SUPPLY * 5 / 100;
        communityAmount = MAX_SUPPLY * 5 / 100;
        maintenanceAmount = MAX_SUPPLY * 5 / 100;
        
        _mint(address(this), MAX_SUPPLY);
        
        emit TokenDistribution(address(this), MAX_SUPPLY, "Initial Mint");
    }
    
    function executeDistribution() external onlyOwner {
        require(!distributionCompleted, "Distribution already completed");
        
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
    
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }
    
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    function maxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }
    
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
    
    function recoverERC20(address tokenAddress, address to, uint256 amount) external onlyOwner {
        require(tokenAddress != address(this), "Cannot recover native token");
        IERC20(tokenAddress).transfer(to, amount);
    }
}
