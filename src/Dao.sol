// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface WorkContract {
    function resolveDispute(bool approveFreelancer) external;
}

contract WorkDAO  {
    IERC20 public stakeToken;
    uint256 public stakeAmount;
    uint256 public voteDuration = 2 minutes;
    address public adminResolve;

    struct Dispute {
        address workContract;
        bool resolved;
        uint256 votesForFreelancer;
        uint256 votesForEmployer;
        mapping(address => bool) hasVoted;
        address[] voters;
        uint256 startTime;
    }
    
    mapping(uint256 => Dispute) public disputes;
    mapping(address => bool) public isValidator;
    mapping(address => uint256) public validatorStake;
    uint256 public disputeCount;
    
    event DisputeOpened(uint256 indexed disputeId, address indexed workContract);
    event VoteCast(uint256 indexed disputeId, address indexed validator, bool vote);
    event DisputeResolved(uint256 indexed disputeId, bool freelancerWins);
    
    constructor(address _stakeToken, uint256 _stakeAmount, address _adminResolved) {
        stakeToken = IERC20(_stakeToken);
        stakeAmount = _stakeAmount;
        adminResolve = _adminResolved;
    }

    modifier onlyAdminResolved() {
        require(msg.sender == adminResolve, "No puede ejecutar esta funcion");
        _;
    }
    
    function registerValidator() external {
        require(!isValidator[msg.sender], "Ya eres validador");
        require(stakeToken.transferFrom(msg.sender, address(this), stakeAmount), "Fallo el stake");
        isValidator[msg.sender] = true;
        validatorStake[msg.sender] = stakeAmount;
    }
    
    function openDispute(address _workContract) external {
        require(msg.sender == _workContract, "No puede llamar a esta funcion");
    
        Dispute storage newDispute = disputes[disputeCount];
        newDispute.workContract = _workContract;
        newDispute.resolved = false;
        newDispute.votesForFreelancer = 0;
        newDispute.votesForEmployer = 0;
        newDispute.startTime = block.timestamp;

        emit DisputeOpened(disputeCount, _workContract);
        disputeCount++;
}
    
    function voteOnDispute(uint256 _disputeId, bool voteForFreelancer) external {
        require(isValidator[msg.sender], "No eres validador");
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "La disputa ya fue resuelta");
        require(!dispute.hasVoted[msg.sender], "Ya votaste en esta disputa");
        require(block.timestamp <= dispute.startTime + voteDuration, "Tiempo de votacion expirado");
        
        dispute.hasVoted[msg.sender] = true;
        dispute.voters.push(msg.sender);
        
        if (voteForFreelancer) {
            dispute.votesForFreelancer++;
        } else {
            dispute.votesForEmployer++;
        }
        
        emit VoteCast(_disputeId, msg.sender, voteForFreelancer);
    }
    
    function resolveDispute(uint256 _disputeId) external onlyAdminResolved {
        Dispute storage dispute = disputes[_disputeId];
        require(!dispute.resolved, "Ya resuelto");
        require(block.timestamp > dispute.startTime + voteDuration, "Tiempo de votacion en curso");
        
        bool freelancerWins = dispute.votesForFreelancer > dispute.votesForEmployer;
        WorkContract(dispute.workContract).resolveDispute(freelancerWins);
        dispute.resolved = true;
        
        emit DisputeResolved(_disputeId, freelancerWins);
    }
}


