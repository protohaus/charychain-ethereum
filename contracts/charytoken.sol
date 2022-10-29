// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 
//Imports 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


//Open zeppelin Contract to mint Charytoken 
contract CharyToken is ERC20, ERC20Burnable{
    address public admin;
    
    constructor() ERC20 ("CharityToken", "CT"){
        _mint(msg.sender, 10000 * 10**18); 
        admin = msg.sender; 
    }

    function mint(address to, uint amount) external {
        require(msg.sender == admin, "only admin can mint"); 
        _mint(to, amount); 
    }
 
    function burnFrom(address donator, uint amount) public override {
        _spendAllowance(donator, _msgSender(), amount); //so? -> dann für jeden account im array ein mal am ende
        _burn(donator, amount); 
    }
    
    //verleiht Recht zu spenden, tx.origin not good solution, should be changed
    function approve(address spender, uint amount) public override returns(bool) {
        address owner = tx.origin; 
        _approve(owner, spender, amount);
        return true; 
    }
}
