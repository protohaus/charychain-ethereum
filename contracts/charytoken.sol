// SPDX-License-Identifier: MIT
pragma solidity = 0.8.13; 

//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

//want to add mintable? 
//ERC20Pausable to make it non-transferable? 
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
    //when this function is called only own tokens can be burned, can there be self destroyable tokens that burn themselfes
    //after a period of time? -> otherwise map account to token and iterate which accounts have not send their tokens
    //needs ether in contract to do so?? 
    function burnFrom(address donator, uint amount) public override {
        _spendAllowance(donator, _msgSender(), amount); //so? -> dann für jeden account im array ein mal am ende
        _burn(donator, amount); 
    }
    //burnable
    //non-transferable 
    //verleiht Recht zu spenden 
}