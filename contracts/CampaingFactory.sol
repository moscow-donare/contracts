// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Campaign.sol"; // asume que Campaign ya importa Ownable y define constructor(owner, creator, …)

contract CampaignFactory is Ownable {
    uint256 public nextId;
    address[] public allCampaigns;
    mapping(address => address[]) public campaignsOf;

    event CampaignCreated(uint256 indexed id, address campaignAddr, address creator);

    function createCampaign(
        string memory title,
        string memory description,
        string memory imageCID,
        address beneficiary,
        uint256 goal,
        uint256 deadline,
        string memory url
    ) external {
        // Validación: solo 1 campaña EnRevision o Activa
        for (uint i; i < campaignsOf[msg.sender].length; ++i) {
            Campaign c = Campaign(campaignsOf[msg.sender][i]);
            Campaign.State st = c.state();
            require(
                st != Campaign.State.EnRevision && st != Campaign.State.Activa,
                "Tienes campaña vigente"
            );
        }

        uint256 id = nextId++;
        // owner() es la cuenta de Donare, msg.sender es el organizador
        Campaign camp = new Campaign(
            owner(),
            msg.sender,
            id,
            title,
            description,
            imageCID,
            beneficiary,
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
