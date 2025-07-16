// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Campaign.sol";

contract CampaignFactory is Ownable {
    uint256 public nextId;
    address[] public allCampaigns;
    mapping(address => address[]) public campaignsOf;

    event CampaignCreated(uint256 indexed id, address campaignAddr, address creator);

    function createCampaign(
        string memory title,
        string memory description,
        string memory imageCID,
        uint256 goal,
        uint256 deadline,
        string memory url
    ) external {
        // Validación: solo una campaña en revisión o activa a la vez por address
        for (uint i = 0; i < campaignsOf[msg.sender].length; ++i) {
            Campaign c = Campaign(campaignsOf[msg.sender][i]);
            Campaign.State st = c.status();
            require(
                st != Campaign.State.InReview && st != Campaign.State.Approved && st != Campaign.State.Paused,
                "Ya tienes una campaña activa o en revisión"
            );
        }

        uint256 id = nextId++;

        Campaign camp = new Campaign(
            owner(),        // Donare (admin)
            msg.sender,     // Creador y beneficiario
            id,
            title,
            description,
            imageCID,
            goal,
            deadline,
            url
        );

        allCampaigns.push(address(camp));
        campaignsOf[msg.sender].push(address(camp));

        emit CampaignCreated(id, address(camp), msg.sender);
    }

    function all() external view returns (address[] memory) {
        return allCampaigns;
    }
}
