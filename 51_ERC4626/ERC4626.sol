// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IERC4626} from "51_ERC4626/IERC4626.sol";
import {ERC20, IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC4626 is ERC20,IERC4626 {
    //状态变量
    ERC20 private immutable _asset;//代币合约地址
    uint8 private immutable _decimals;//小数位数
    constructor (ERC20 asset_,string memory name_,string memory symbol_) ERC20(name_,symbol_)  {
        _asset = asset_;
        _decimals = asset_.decimals();
    }
    //返回代币合约地址
    function asset() public view virtual override returns (address){
        return address(_asset);
    }
    //返回小数位数
    function decimals() public view virtual override(IERC20Metadata,ERC20) returns (uint8) {
        return _decimals;
    }
    //存款 调用者存入assets份额的基础资产 得到shares份额的金库资产
    function deposit(uint256 assets,address receiver) public virtual returns (uint256 shares) {
        //计算获得的金库份额
        shares = previewDeposit(assets);
        _asset.transferFrom(msg.sender,address(this),assets);
        _mint(receiver,shares);

        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    //调用者想铸造shares份额的金库额度 
    function mint(uint256 shares,address receiver) public virtual returns(uint256 assets) {
        //计算需要存入的基础金额
        assets = previewMint(shares);
        _asset.transferFrom(msg.sender,address(this),assets);
        _mint(receiver,shares);
        // 释放 Deposit 事件
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    //提款函数
    function withdraw(uint256 assets,address receiver,address owner) public virtual returns (uint256 shares) {
        //计算要销毁的金库份额
        shares = previewWithdraw(assets);
        if (msg.sender != owner) {
            //检查并更新授权
            _spendAllowance(owner,msg.sender,shares);
        }
        _burn(owner, shares);
        _asset.transfer(receiver,assets);
         // 释放 Withdraw 函数
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    //赎回函数
    function redeem(uint256 shares,address receiver,address owner) public virtual returns (uint256 assets) {
        //计算能赎回的基础资产
        assets = previewRedeem(shares);
        if (msg.sender != owner) {
            //检查并更新授权
            _spendAllowance(owner,msg.sender,shares);
        }
        _burn(owner,shares);
        _asset.transfer(receiver,assets);
         // 释放 Withdraw 函数
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }
    function previewMint(uint256 shares) public view virtual returns (uint256){
        return convertToAssets(shares);
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256){
        uint256 supply = totalSupply();
        //如果金库份额为0  则一比一返回 反之则按金库份额比例返回
        return supply == 0 ? shares : shares * totalAssets() / supply; 
    }
    //返回合约的基础资产持仓量
    function totalAssets() public view virtual override returns (uint256){
        return _asset.balanceOf(address(this));
    }
    function convertToShares(uint256 assets) public view virtual returns (uint256){
        //金库份额的代币总数
        uint256 supply = totalSupply();
        //总数为0 就一比一铸造 不为0 则按用户基础资产占总基础资产的比例铸造
        return supply == 0 ? assets : assets * supply / totalAssets();
    }
    //计算能获得的金库份额
    function previewDeposit(uint256 assets) public view virtual returns(uint256) {
        return convertToShares(assets);
    }
    //单次最大可存款
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    //单次最大可铸造
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    //单次最大可取
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }
    //单次最大可赎回
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf(owner);
    }
}