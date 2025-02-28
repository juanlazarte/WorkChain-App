// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface WorkDAO {
    function openDispute(address workContract) external;
}

contract WorkContract {
    IERC20 public paymentToken;
    address public employer;
    address public freelancer;
    uint256 public paymentAmount;
    uint256 public amountDeposited;
    bool public workCompleted;
    bool public disputed;
    bool public paymentReleased; // Para evitar pagos duplicados
    WorkDAO public workDao;

    string public jobTitle;
    string public jobDescription;
    uint256 public deadline;
    bool public isStarted;

    event WorkStarted(address freelancer);
    event WorkCompleted(address freelancer);
    event PaymentReleased(address freelancer, uint256 amount);
    event DisputeOpened(address indexed contractAddress);
    event DisputeResolved(bool freelancerWins);
    event WorkSubmitted(address freelancer);
    event FundsDeposited(address employer, uint256 amount);

    constructor(
        address _paymentToken,
        address _employer,
        address _freelancer,
        uint256 _paymentAmount,
        address _workDao,
        string memory _jobTitle,
        string memory _jobDescription,
        uint256 _deadline
    ) {
        paymentToken = IERC20(_paymentToken);
        employer = _employer;
        freelancer = _freelancer;
        paymentAmount = _paymentAmount;
        workDao = WorkDAO(_workDao);
        jobTitle = _jobTitle;
        jobDescription = _jobDescription;
        deadline = _deadline;

        paymentReleased = false;
        workCompleted = false;
        disputed = false;
        isStarted = false;
        amountDeposited = 0;
    }

    modifier onlyEmployerOrFreelancer() {
        require(msg.sender == employer || msg.sender == freelancer, "No autorizado");
        _;
    }

    modifier onlyEmployer() {
        require(msg.sender == employer, "No autorizado");
        _;
    }

    function depositFunds() external {
        require(msg.sender == employer, "Solo el empleador puede depositar fondos");
        require(!paymentReleased , "El pago ya se realizo");
        require(amountDeposited == 0, "Fondos ya depositados");
        require(paymentToken.transferFrom(msg.sender, address(this), paymentAmount), "Fallo la transferencia");
        amountDeposited = paymentAmount;
        emit FundsDeposited(msg.sender, paymentAmount);
    }

    function startWork() external {
        require(msg.sender == freelancer, "Solo el freelancer puede iniciar el trabajo");
        require(!isStarted, "El trabajo ya ha comenzado");
        isStarted = true;
        emit WorkStarted(msg.sender);
    }

    function markWorkCompleted() external {
        require(msg.sender == freelancer, "Solo el freelancer puede marcarlo");
        require(isStarted, "El trabajo debe haber iniciado");
        require(!workCompleted, "El trabajo ya se completo");
        workCompleted = true;
        emit WorkCompleted(freelancer);
    }

    function releasePayment() external onlyEmployer {
        require(workCompleted, "El trabajo no ha sido completado");
        require(!disputed, "El pago esta en disputa");
        require(!paymentReleased, "El pago ya ha sido realizado");
        require(amountDeposited >= paymentAmount, "Fondos insuficientes");

        paymentReleased = true; // Bloquea futuros pagos
        amountDeposited = 0; // Se vacían los fondos del contrato

        require(paymentToken.transfer(freelancer, paymentAmount), "Fallo la transferencia");

        emit PaymentReleased(freelancer, paymentAmount);
    }

    function openDispute() external onlyEmployerOrFreelancer { 
        require(!disputed, "Ya existe una disputa");
        require(workCompleted, "El trabajo aun no ha sido completado");
        require(!paymentReleased, "No se puede disputar un trabajo ya pagado"); // Nueva validación

        disputed = true;
        workDao.openDispute(address(this));

        emit DisputeOpened(address(this));
    }

    function resolveDispute(bool approveFreelancer) external {
        require(msg.sender == address(workDao), "Solo la DAO puede resolver");
        require(disputed, "No hay disputa activa");

        disputed = false;
        paymentReleased = true; // Marcar como resuelto

        if (approveFreelancer) {
            require(paymentToken.transfer(freelancer, paymentAmount), "Fallo la transferencia");
            emit PaymentReleased(freelancer, paymentAmount);
        } else {
            require(paymentToken.transfer(employer, paymentAmount), "Fallo la transferencia");
        }

        amountDeposited = 0; // Se vacía el saldo tras la disputa
        emit DisputeResolved(approveFreelancer);
    }
}
