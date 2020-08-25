pragma solidity ^0.6.4;

import "./IManaged.sol";
import "./Controller.sol";
import "../curation/ICuration.sol";
import "../epochs/IEpochManager.sol";
import "../rewards/IRewardsManager.sol";
import "../staking/IStaking.sol";
import "../token/IGraphToken.sol";

/**
 * @title Graph Managed contract
 * @dev The Managed contract provides an interface for contracts to interact with the Controller
 * Inspired by Livepeer:
 * https://github.com/livepeer/protocol/blob/streamflow/contracts/Controller.sol
 */
contract Managed {
    // Controller that contract is registered with
    Controller public controller;

    event ParameterUpdated(string param);
    event SetController(address controller);

    modifier notRecoveryPaused {
        require(
            !controller.paused(),
            "This action cannot be performed while the contract is paused"
        );
        require(
            !controller.recoveryPaused(),
            "This action cannot be performed while the contract is recovery paused"
        );
        _;
    }

    modifier notPaused {
        require(
            !controller.paused(),
            "This action cannot be performed while the contract is paused"
        );
        _;
    }

    // Check if sender is controller
    modifier onlyController() {
        require(msg.sender == address(controller), "Caller must be Controller");
        _;
    }

    modifier onlyGovernor() {
        require(msg.sender == controller.governor(), "Caller must be Controller governor");
        _;
    }

    modifier onlyStaking() {
        require(msg.sender == address(staking()), "Caller must be the staking contract");
        _;
    }

    modifier onlyCuration() {
        require(msg.sender == address(curation()), "Caller must be the curation contract");
        _;
    }

    modifier onlyRewardsManager() {
        require(
            msg.sender == address(rewardsManager()),
            "Caller must be the rewards manager contract"
        );
        _;
    }

    modifier onlyGraphToken() {
        require(msg.sender == address(graphToken()), "Caller must be the graph token contract");
        _;
    }

    /**
     * @dev Initialize the controller
     */
    function _initialize(address _controller) internal {
        controller = Controller(_controller);
    }

    /**
     * @notice Set Controller. Only callable by current controller
     * @param _controller Controller contract address
     */
    function setController(address _controller) external onlyController {
        controller = Controller(_controller);
        emit SetController(_controller);
    }

    /**
     * @dev Return Curation interface
     * @return Curation contract registered with Controller
     */
    function curation() internal view returns (ICuration) {
        return ICuration(controller.getContractProxy(keccak256("Curation")));
    }

    /**
     * @dev Return EpochManager interface
     * @return Epoch manager contract registered with Controller
     */
    function epochManager() internal view returns (IEpochManager) {
        return IEpochManager(controller.getContractProxy(keccak256("EpochManager")));
    }

    /**
     * @dev Return RewardsManager interface
     * @return Rewards manager contract registered with Controller
     */
    function rewardsManager() internal view returns (IRewardsManager) {
        return IRewardsManager(controller.getContractProxy(keccak256("RewardsManager")));
    }

    /**
     * @dev Return Staking interface
     * @return Staking contract registered with Controller
     */
    function staking() internal view returns (IStaking) {
        return IStaking(controller.getContractProxy(keccak256("Staking")));
    }

    /**
     * @dev Return GraphToken interface
     * @return Graph token contract registered with Controller
     */
    function graphToken() internal view returns (IGraphToken) {
        return IGraphToken(controller.getContractProxy(keccak256("GraphToken")));
    }
}
