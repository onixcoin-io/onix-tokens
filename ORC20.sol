// SPDX-License-Identifier: MIT
// OnixCoin ERC20 token implementation
// Version 1.0.0

pragma solidity ^0.8.0;

import "../openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ORC20 is ERC20, ERC20PresetMinterPauser {
    
    uint8 private _decimals = 8;
    
    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC20-constructor}.
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals_
    ) ERC20PresetMinterPauser(name, symbol) {
        _mint(_msgSender(), initialSupply);
        _decimals = decimals_;
    }

    function decimals() public view virtual override(ERC20) returns (uint8) {
        return _decimals;
    }
    
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
