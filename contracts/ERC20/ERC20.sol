// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    string _name;
    string _symbol;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;

    constructor(
        string memory name_,
        string memory symbol_,
        uint initialSupply_,
        address shop_
    ) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;
        mint(initialSupply_, shop_);
    }

    modifier enoughTokens(address _from, uint _amount) {
        require(balanceOf(_from) >= _amount, "Insufficient funds.");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner.");
        _;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function decimals() external pure override returns (uint) {
        return 18; // 1 token = 1 wei
    }

    function burn(
        address _from,
        uint amount
    ) external onlyOwner enoughTokens(_from, amount) {
        _beforeTokenTransferred(_from, address(0), amount);
        balances[_from] -= amount;
        totalTokens -= amount;
    }

    function mint(uint amount, address shop) public onlyOwner {
        _beforeTokenTransferred(address(0), shop, amount);
        balances[shop] += amount;
        totalTokens += amount;
        emit Transfer(address(0), shop, amount);
    }

    function totalSupply() external view override returns (uint) {
        return totalTokens;
    }

    function balanceOf(address account) public view override returns (uint) {
        return balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) external enoughTokens(msg.sender, amount) {
        _beforeTokenTransferred(msg.sender, to, amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
    }

    function allowance(
        address _owner,
        address spender
    ) public view returns (uint) {
        return allowances[_owner][spender];
    }

    function approve(address spender, uint amount) public {
        _approve(msg.sender, spender, amount);
    }

    function _approve(
        address sender,
        address spender,
        uint amount
    ) internal virtual {
        allowances[sender][spender] = amount;
        emit Approve(sender, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external enoughTokens(sender, amount) {
        _beforeTokenTransferred(sender, recipient, amount);
        // require(allowances[sender][recipient] >= amount, "check allowance");
        allowances[sender][recipient] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _beforeTokenTransferred(
        address from,
        address to,
        uint amount
    ) internal virtual {}
}

contract MCSToken is ERC20 {
    constructor(address shop) ERC20("MCSToken", "MCT", 20, shop) {}
}

contract MShop {
    IERC20 public token;
    address payable public owner;

    event Bought(uint _amount, address indexed _buyer);
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        token = new MCSToken(address(this));
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner.");
        _;
    }

    function sell(uint _amountToSell) external {
        require(
            _amountToSell > 0 && token.balanceOf(msg.sender) >= _amountToSell,
            "Incorrect amount"
        );

        uint allowance = token.allowance(msg.sender, address(this));
        require(allowance >= _amountToSell, "Check the allowance");
        token.transferFrom(msg.sender, address(this), _amountToSell);

        payable(msg.sender).transfer(_amountToSell);

        emit Sold(_amountToSell, msg.sender);
    }

    receive() external payable {
        uint tokensToBuy = msg.value;
        require(tokensToBuy > 0, "Insufficient funds");

        require(tokenBalance() >= tokensToBuy, "Not enough tokens to buy");

        token.transfer(msg.sender, tokensToBuy);
        emit Bought(tokensToBuy, msg.sender);
    }

    function tokenBalance() public view returns (uint) {
        return token.balanceOf(address(this));
    }
}
