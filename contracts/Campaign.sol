// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Campaign is Ownable, ReentrancyGuard {
    enum State {
        InReview,
        PendingChanges,
        Active,
        Cancelled,
        Completed
    }

    enum Category {
        Health,
        Education,
        Emergency,
        Raffle,
        Project
    }

    State public status;
    address public creator;
    uint256 public goal;
    uint256 public raised;
    uint256 public deadline;
    uint256 public id;
    Category public category;

    IERC20 public usdtToken;

    string public title;
    string public description;
    string public imageCID;
    string public url;

    mapping(address => uint256) public contributions;

    event StateChanged(State newState, string reason);
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
    string memory _url,
    uint8 _category, 
    address _usdtTokenAddress
) {
    require(_goal > 0, "Goal must be greater than 0");
    require(_deadline > block.timestamp, "Deadline must be in the future");
    require(_category <= uint8(Category.Project), "Invalid category");

    _transferOwnership(_owner);
    //TODO: VALIDAR SI ES NECESARIO DEPLOYAR BENEFICIARY Y CREADOR
    creator = _creator;
    id = _id;
    title = _title;
    description = _description;
    imageCID = _imageCID;
    goal = _goal;
    deadline = _deadline;
    url = _url;
    status = State.Active;
    category = Category(_category);

    usdtToken = IERC20(_usdtTokenAddress);
}

    modifier onlyCreator() {
        require(msg.sender == creator, "Solo el creador");
        _;
    }

    modifier onlyActive() {
        require(status == State.Active, "La campania no esta activa");
        _;
    }

    modifier notFinal() {
        require(
            status != State.Completed && status != State.Cancelled,
            "Campania finalizada"
        );
        _;
    }

    function editCampaign(
        string memory _title,
        string memory _description,
        string memory _imageCID,
        uint256 _goal,
        uint256 _deadline,
        string memory _url,
        string calldata reason
    ) external onlyCreator notFinal {
        require(status != State.InReview, "Ya esta en revision");
        require(_goal > 0, "Meta invalida");
        require(_deadline > block.timestamp, "Deadline invalido");

        title = _title;
        description = _description;
        imageCID = _imageCID;
        goal = _goal;
        deadline = _deadline;
        url = _url;

        status = State.InReview;
        emit StateChanged(State.InReview, reason);
    }

    // --- Transiciones de estado manuales por Donare (admin) ---
    function approveCampaign(string calldata reason) external onlyOwner {
        status = State.Active;
        emit StateChanged(State.Active, reason);
    }

    function requestChanges(string calldata reason) external onlyOwner {
        status = State.PendingChanges;
        emit StateChanged(State.PendingChanges, reason);
    }

    function cancelByAdmin(string calldata reason) external onlyOwner {
        status = State.Cancelled;
        emit StateChanged(State.Cancelled, reason);
    }

    // --- Cambios desde el lado del creador ---
    function markAsEdited(
        string calldata reason
    ) external onlyCreator notFinal {
        status = State.InReview;
        emit StateChanged(State.InReview, reason);
    }

    function cancelByCreator(
        string calldata reason
    ) external onlyCreator notFinal {
        status = State.Cancelled;
        emit StateChanged(State.Cancelled, reason);
    }

    // --- Donaciones ---
    function donate(uint256 amount) external nonReentrant onlyActive {
        require(block.timestamp <= deadline, "Campania vencida");
        require(amount > 0, "Debe enviar fondos");

        bool success = usdtToken.transferFrom(msg.sender, creator, amount);
        require(success, "Transferencia fallida");

        raised += amount;
        contributions[msg.sender] += amount;

        emit Donated(msg.sender, amount);

        if (raised >= goal) {
            status = State.Completed;
            emit StateChanged(
                State.Completed,
                "Se alcanzo el objetivo de recaudacion"
            );
        }
    }

    // --- Finalizar si venció el plazo ---
    function finalizeIfExpired() external {
        require(status == State.Active, "Solo campanias activas");
        require(block.timestamp > deadline, "Aun no vencio");
        status = State.Completed;
        emit StateChanged(State.Completed, "Se alcanzo la fecha limite");
    }
}
