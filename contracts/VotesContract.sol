// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vote is Ownable {
    IERC20 daoToken;

    struct proposalGroup {
        uint256 id;
        uint256[] proposalsIds;
        bool isActive;
        string title;
        string description;
    }

    struct proposalInfo {
        uint256 id;
        string title;
        string description;
        uint256 proposalGroupId;
    }
    uint256 proposalsQuantity;
    uint256 proposalsGroupQuantity;
    mapping(uint256 => proposalInfo) public proposals;
    mapping(uint256 => proposalGroup) public proposalsGroup;
    mapping(uint256 => uint256) public proposalIdVotes;
    mapping(address => uint256[]) public userVotesGroups;

    constructor(address _daoToken) {
        daoToken = IERC20(_daoToken);
    }

    function createProposalGroup(
        string memory _title,
        string memory _description
    ) public onlyOwner {
        proposalsGroupQuantity = proposalsGroupQuantity + 1;
        proposalsGroup[proposalsGroupQuantity - 1] = proposalGroup(
            proposalsGroupQuantity,
            new uint256[](0),
            true,
            _title,
            _description
        );
    }

    function createProposal(
        uint256 _proposalGroupId,
        string memory _title,
        string memory _description
    ) public onlyOwner {
        require(
            proposalsGroup[_proposalGroupId].isActive != true,
            "Group not active"
        );

        proposalsQuantity = proposalsQuantity + 1;
        proposals[proposalsQuantity - 1] = proposalInfo(
            proposalsQuantity,
            _title,
            _description,
            _proposalGroupId
        );

        proposalsGroup[_proposalGroupId].proposalsIds.push(proposalsQuantity);
    }

    function vote(uint256 _proposalId) public {
        require(
            daoToken.balanceOf(_msgSender()) > 0,
            "You must have the DAO token"
        );

        proposalInfo memory proposal = proposals[_proposalId - 1];

        require(proposal.proposalGroupId > 0, "Proposal Id not valid");

        proposalGroup memory propGroup = proposalsGroup[
            proposal.proposalGroupId - 1
        ];

        require(propGroup.isActive, "Proposal Group not active");

        uint256[] memory voteGroups = userVotesGroups[_msgSender()];
        for (uint256 i = 0; i < voteGroups.length; i++) {
            require(
                voteGroups[i] != proposal.proposalGroupId,
                "Vote already did on this group"
            );
        }

        userVotesGroups[_msgSender()].push(proposal.proposalGroupId);
        uint256 currentVotes = proposalIdVotes[_proposalId];
        proposalIdVotes[_proposalId] = currentVotes + 1;
    }

    function getProposalById(uint256 _proposalId)
        public
        view
        returns (proposalInfo memory)
    {
        uint256 proposalGroupId = proposals[_proposalId - 1].proposalGroupId;
        require(proposalGroupId > 0, "Proposal Id not valid");
        return proposals[_proposalId - 1];
    }

    function getProposalsIdsByGroupId(uint256 _groupId)
        public
        view
        returns (uint256[] memory)
    {
        return proposalsGroup[_groupId].proposalsIds;
    }

    function getProposalsGroups() public view returns (proposalGroup[] memory) {
        proposalGroup[] memory proposalsGroupsToReturn = new proposalGroup[](
            proposalsGroupQuantity
        );
        for (uint256 i = 0; i < proposalsGroupQuantity; i++) {
            proposalGroup storage proposalGroupToAdd = proposalsGroup[i];
            proposalsGroupsToReturn[i] = proposalGroupToAdd;
        }
        return proposalsGroupsToReturn;
    }

    function getProposalsGroupById(uint256 _groupId)
        public
        view
        returns (proposalGroup memory)
    {
        return proposalsGroup[_groupId];
    }

    function getProposalVotesById(uint256 _proposalId)
        public
        view
        returns (uint256)
    {
        return proposalIdVotes[_proposalId];
    }
}
