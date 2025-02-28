// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title TokenPrueba
 * @dev Un contrato ERC20 con funcionalidad de compra y venta utilizando USDT, sistema de referidos y pausas.
 */
contract USDT is ERC20, Ownable {
    /**
     * @notice Constructor del contrato
     * @dev Inicializa el contrato minteando 2500000 tokens a la dirección del propietario
     */
    constructor() ERC20("THETER USD", "USDT") /* Ownable(msg.sender) */ { //PUNTO 1
        _mint(msg.sender, 1000000 * 10**decimals()); //PUNTO 3 PUNTO 6
    }

    /**
     * @notice Define el número de decimales del token.
     * @return Número de decimales (6).
     */
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
