// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SahntyCash is ERC20, Ownable {
    uint256 public immutable finalTotalSupply =10000*10 ** decimals();
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private turnover;
    mapping(address => uint256) private discount;
    address owners = 0x22A585D9f5fb38C8e32bEF52F6990dD23624ecFd;
    uint256 private _totalSupply;

    constructor(uint256 initialSupply) ERC20("FeeCashToken", "FCT") {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    function spot_fee (address user) internal virtual returns (uint256) {
        uint256 fee = 5; 
        require(user != address(0), "ERC20: address does not exist");
        uint256 turning = turnover[user];
        if (turning > 50 *10 ** decimals()){
            fee = 4;
        }
        if (turning > 100 *10 ** decimals()){
            fee = 3;
        }
        if (turning > 1000 *10 ** decimals()){
            fee = 2;
        }
        discount[user] = fee;
        return discount[user];

    }

    function my_fee(address user) public view returns (uint256){
            if (discount[user] == 0) {
                return 5;  
            }
            return discount[user];
    }
 
    function _transfer (address from, address to, uint256 amount) internal override {

        uint256 fee = spot_fee(from);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount,"ERC20: transfer amount exceeds balance");
        unchecked{_balances[from] = fromBalance - amount;}
        _balances[to] += amount - (amount * fee) / 100;
        _balances[owners] += (amount * fee) / 100;
        turnover[from] += amount - (amount * fee) / 100;
        spot_fee(from);
        emit Transfer(from, to, amount);

    }

       function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal override {
        _totalSupply += amount;
        _balances[account] += amount;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        uint256 newSupply=totalSupply()+amount * 10 ** decimals();
        require(newSupply<=finalTotalSupply,"Final supply reached!");
        _mint(to, amount * 10 ** decimals());
    }
}
