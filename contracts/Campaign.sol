// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Campaign is Ownable, ReentrancyGuard {
    enum State { InReview, Approved, Rejected, Paused, Finalized }

    State public status;
    address public creator;
    address public beneficiary;
    uint256 public goal;
    uint256 public raised;
    uint256 public deadline;
    uint256 public id;

    string public title;
    string public description;
    string public imageCID;
    string public url;

    mapping(address => uint256) public contributions;

    event StatusChanged(State newStatus);
    event Donated(address indexed from, uint256 amount);

    constructor(
        address _owner,
        address _creator,
        uint256 _id,
        string memory _title,
        string memory _description,
        string memory _imageCID,
        uint256 _goal,
        uint256 _deadline,
        string memory _url
    ) {
        require(_goal > 0, "Goal must be greater than 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        _transferOwnership(_owner);

        creator     = _creator;
        beneficiary = _creator; // Beneficiario es el creador en el MVP
        id          = _id;
        title       = _title;
        description = _description;
        imageCID    = _imageCID;
        goal        = _goal;
        deadline    = _deadline;
        url         = _url;
        status      = State.InReview;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Solo el creador");
        _;
    }

    modifier notFinalized() {
        require(status != State.Finalized, "Campaña finalizada");
        _;
    }

    function markAsEdited() external onlyCreator {
        require(status != State.Finalized, "No editable");
        status = State.InReview;
        emit StatusChanged(status);
    }

    function setStatus(State newStatus) external onlyOwner {
        require(
            newStatus == State.Approved ||
            newStatus == State.Rejected,
            "Estado inválido"
        );
        status = newStatus;
        emit StatusChanged(newStatus);
    }

    function pause() external onlyOwner {
        require(status != State.Finalized, "No puede pausar campaña finalizada");
        status = State.Paused;
        emit StatusChanged(status);
    }

    function donate() external payable nonReentrant notFinalized {
        require(status == State.Approved, "Campaña no aprobada");
        require(block.timestamp <= deadline, "Campaña vencida");
        require(msg.value > 0, "Debe enviar fondos");

        raised += msg.value;
        contributions[msg.sender] += msg.value;

        // Transferencia directa al beneficiario
        payable(beneficiary).transfer(msg.value);
        emit Donated(msg.sender, msg.value);

        // Verificar si se alcanzó el objetivo
        if (raised >= goal) {
            status = State.Finalized;
            emit StatusChanged(State.Finalized);
        }
    }

    function finalizeIfExpired() external {
        require(status == State.Approved, "Solo campañas activas pueden finalizar");
        require(block.timestamp > deadline, "Aún no venció");
        status = State.Finalized;
        emit StatusChanged(State.Finalized);
    }
}
