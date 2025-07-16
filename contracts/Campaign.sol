// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Campaign is Ownable, ReentrancyGuard {
    enum State { InReview, Approved, Rejected, Paused }

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
    event Refunded(address indexed to, uint256 amount);

    constructor(
        address _owner,      // ← Donare (factory.owner())
        address _creator,    // ← msg.sender del factory
        uint256 _id,
        string memory _title,
        string memory _description,
        string memory _imageCID,
        address _beneficiary,
        uint256 _goal,
        uint256 _deadline,
        string memory _url
    ) {
        _transferOwnership(_owner);
        creator     = _creator;
        id          = _id;
        title       = _title;
        description = _description;
        imageCID    = _imageCID;
        beneficiary = _beneficiary;
        goal        = _goal;
        deadline    = _deadline;
        url         = _url;
        status      = State.InReview;
    }

    modifier onlyCreator() {
        require(msg.sender == creator, "Solo el creador");
        _;
    }

    // El organizador edita → vuelve a InReview
    function markAsEdited() external onlyCreator {
        status = State.InReview;
        emit StatusChanged(status);
    }

    // Solo Donare (owner) aprueba o rechaza
    function setStatus(State newStatus) external onlyOwner {
        require(
            newStatus == State.Approved ||
            newStatus == State.Rejected,
            "Estado inválido"
        );
        status = newStatus;
        emit StatusChanged(newStatus);
    }

    // Pausar por seguridad
    function pause() external onlyOwner {
        status = State.Paused;
        emit StatusChanged(status);
    }

    // ----------------------------------------------------
    // Donaciones y reembolsos
    // ----------------------------------------------------
    function donate() external payable {
        require(status == State.Approved, "No activa");
        contributions[msg.sender] += msg.value;
        raised += msg.value;
        emit Donated(msg.sender, msg.value);
    }

    function refund(uint256 amount) external nonReentrant {
        require(contributions[msg.sender] >= amount, "No contribuiste tanto");
        contributions[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Refunded(msg.sender, amount);
    }
}
