// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./WorkContract.sol";

/// @title ContractFactory - Fábrica de contratos de trabajo
contract ContractFactory  {
    address[] public workContracts;
    event WorkContractCreated(address indexed contractAddress, address indexed employer, address indexed freelancer);
    
    function createWorkContract(
        address _freelancer, 
        uint256 _amount, 
        address _paymentToken,
        string memory _jobTitle,
        address _workDao,
        string memory _jobDescription,
        uint256 _deadline
    ) external {
        WorkContract newContract = new WorkContract(_paymentToken, msg.sender, _freelancer, _amount, _workDao, _jobTitle, _jobDescription, _deadline);
        workContracts.push(address(newContract));
        emit WorkContractCreated(address(newContract), msg.sender, _freelancer);
    }
}