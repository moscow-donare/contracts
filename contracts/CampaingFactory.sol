// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Campaign.sol";

contract CampaignFactory is Ownable {
    uint256 public nextId;
    address[] public allCampaigns;
    mapping(address => address[]) public campaignsOf;

    address public usdtTokenAddress;

    event CampaignCreated(
        uint256 indexed id,
        address campaignAddr,
        address creator
    );

    constructor(address _usdtTokenAddress) {
        usdtTokenAddress = _usdtTokenAddress;
    }

    function createCampaign(
        address creator,
        string memory title,
        string memory description,
        string memory imageCID,
        uint256 goal,
        uint256 deadline,
        string memory url,
        uint8 category
    ) external {
        // Solo puede haber una campaña en estado no finalizado por usuario
        for (uint i = 0; i < campaignsOf[creator].length; ++i) {
            Campaign c = Campaign(campaignsOf[creator][i]);
            Campaign.State st = c.status();
            if (
                st == Campaign.State.InReview ||
                st == Campaign.State.PendingChanges ||
                st == Campaign.State.Active
            ) {
                revert("Ya tienes una campania activa o pendiente");
            }
        }

        uint256 id = nextId++;

        Campaign newCampaign = new Campaign(
            owner(), // Donare (admin)
            creator, // Beneficiario / creador
            id,
            title,
            description,
            imageCID,
            goal,
            deadline,
            url,
            category,
            usdtTokenAddress
        );

        allCampaigns.push(address(newCampaign));
        campaignsOf[creator].push(address(newCampaign));

        emit CampaignCreated(id, address(newCampaign), creator);
    }

    function all() external view returns (address[] memory) {
        return allCampaigns;
    }

    function campaignsByUser (
        address user
    ) external view returns (address[] memory) {
        return campaignsOf[user];
    }

    function campaignsById (
        uint256 id
    ) external view returns (address) {
        return allCampaigns[id];
    }

    function setUsdtTokenAddress(address newAddress) external onlyOwner {
        usdtTokenAddress = newAddress;
    }
}
