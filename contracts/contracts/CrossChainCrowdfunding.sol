// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@zetachain/protocol-contracts/contracts/zevm/SystemContract.sol";
import "@zetachain/protocol-contracts/contracts/zevm/interfaces/zContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@zetachain/toolkit/contracts/BytesHelperLib.sol";
import "@zetachain/toolkit/contracts/OnlySystem.sol";

contract CrossChainCrowdfunding is ERC20, zContract, OnlySystem {
    SystemContract public systemContract;
    uint256 public immutable chainID;
    uint256 constant BITCOIN = 18332;

    struct Project {
        address owner;
        uint256 goal;
        uint256 deadline;
        uint256 totalFunds;
        bool isFunded;
        mapping(bytes => uint256) pledges;
    }

    uint256 public projectCounter;
    mapping(uint256 => Project) public projects;

    error WrongChain(uint256 chainID);
    error UnknownAction(uint8 action);
    error InvalidProject();
    error ProjectFundingEnded();
    error InsufficientFunds();
    error NotProjectOwner();
    error ProjectGoalNotReached();
    error ProjectStillOngoing();

    event ProjectCreated(uint256 projectId, address owner, uint256 goal, uint256 deadline);
    event ProjectFunded(uint256 projectId, bytes funder, uint256 amount);
    event ProjectGoalReached(uint256 projectId);
    event FundsWithdrawn(uint256 projectId, uint256 amount);

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 chainID_,
        address systemContractAddress
    ) ERC20(name_, symbol_) {
        systemContract = SystemContract(systemContractAddress);
        chainID = chainID_;
    }

    function onCrossChainCall(
        zContext calldata context,
        address zrc20,
        uint256 amount,
        bytes calldata message
    ) external virtual override onlySystem(systemContract) {
        if (chainID != context.chainID || chainID != BITCOIN) {
            revert WrongChain(context.chainID);
        }

        uint8 action = chainID == BITCOIN
            ? uint8(message[0])
            : abi.decode(message, (uint8));

        if (action == 1) {
            uint256 projectId;
            if (chainID == BITCOIN) {
                projectId = bytesToUint256(message, 1);
            } else {
                (,projectId) = abi.decode(message, (uint8, uint256));
            }
            fundProject(context.origin, projectId, amount);
        } else {
            revert UnknownAction(action);
        }
    }

     function bytesToUint256(bytes memory b, uint256 offset) internal pure returns (uint256) {
        require(b.length >= offset + 32, "Invalid byte length for Uint256");
        uint256 result;
        assembly {
            result := mload(add(b, add(32, offset)))
        }
        return result;
    }

    function createProject(uint256 goal, uint256 duration) external {
        require(goal > 0, "Goal must be positive");
        require(duration > 0, "Duration must be positive");

        projectCounter++;

        Project storage newProject = projects[projectCounter];
        newProject.owner = msg.sender;
        newProject.goal = goal;
        newProject.deadline = block.timestamp + duration;
        newProject.isFunded = false;
        newProject.totalFunds = 0;

        emit ProjectCreated(projectCounter, msg.sender, goal, newProject.deadline);
    }

    function fundProject(bytes memory funder, uint256 projectId, uint256 amount) internal {
        if (projectId == 0 || projectId > projectCounter) revert InvalidProject();

        Project storage project = projects[projectId];
        if (block.timestamp >= project.deadline) revert ProjectFundingEnded();
        if (project.isFunded) revert ProjectFundingEnded();

        project.totalFunds += amount;
        project.pledges[funder] += amount;
        emit ProjectFunded(projectId, funder, amount);

        if (project.totalFunds >= project.goal) {
            project.isFunded = true;
            emit ProjectGoalReached(projectId);
        }
    }

    function withdrawFunds(uint256 projectId) external {
        Project storage project = projects[projectId];
        if (msg.sender != project.owner) revert NotProjectOwner();
        if (!project.isFunded) revert ProjectGoalNotReached();
        if (block.timestamp < project.deadline) revert ProjectStillOngoing();

        uint256 amount = project.totalFunds;
        project.totalFunds = 0;

        address zrc20 = systemContract.gasCoinZRC20ByChainId(chainID);
        IZRC20(zrc20).transfer(project.owner, amount);

        emit FundsWithdrawn(projectId, amount);
    }
}