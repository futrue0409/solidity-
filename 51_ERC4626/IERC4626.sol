// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IERC4626 is IERC20,IERC20Metadata {
    //存款事件 向金库存asserts单位的基础资产 合约铸造shares单位的金库额度给owner地址
     event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    //提款事件 owner地址销毁shares单位的金库额度 然后合约将assets单位的基础资产发给receiver地址
     event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    //元数据 返回金库的基础资产代币地址 必须是ERC20代币合约地址 不能回退
    function asset() external view returns (address assetTokenAddress);
    //存款函数 用户向金库存入assets单位的基础资产 合约铸造shares单位的金库额度给receiver地址 释放存款事件 如果资产不能存入 必须回退
    function deposit(uint256 assets,address receiver) external returns(uint256 shares);
    //用户存入资产后铸造 如果不够铸造 必须回退
    function mint(uint256 shares,address receiver) external returns (uint256 assets);
    //提款函数 owner地址销毁shares单位的金库额度 然后合约将assets的基础资产发送给receiver地址 
    function withdraw(uint256 assets,address receiver,address owner) external returns(uint256 shares);
    //赎回函数 同提款
    function redeem(uint256 shares,address receiver,address owner) external returns (uint256 assets);
    //返回金库中管理的基础资产代币总额 包含利息和费用
    function totalAssets() external view returns(uint256 totalManagedAssets);
    //返回利用assets数额的基础资产可以换取的金库额度 不包含费用和滑点 不能回退
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    //返回利用一定数额金库额度可以换取的基础资产 不要包含费用和滑点 不能回退
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    //用于链上和链下用户在当前链上环境模拟存款一定数额的基础资产能够获取的金库数额 
    //返回值要不大于在同一交易进行存款得到的金库额度
    //不要考虑 maxDeposit 等限制，假设用户的存款交易会成功 要考虑费用 不能回退
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    //模拟铸造
    function previewMint(uint256 shares) external view returns (uint256 assets);
    //模拟提款
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);
    //模拟赎回
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    //返回用户单次可存的最大基础资产数额
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);
    //最大铸造
    function maxMint(address receiver) external view returns (uint256 maxShares);
    //最大取出
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);
    //最大销毁
    function maxRedeem(address owner) external view returns (uint256 maxShares);
}