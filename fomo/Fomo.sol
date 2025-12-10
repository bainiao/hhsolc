// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Fomo{
    struct Pool{
        address poolOnwer;
        uint64 numberOfMachines;
        uint64 priceOfMachine;
        uint64 totalInMachines;  // total machines actually bought
        Buyer[] buyers;
    }
    struct Buyer{
        address buyerAddress;
        uint112 nMachines;  // want to buy
        uint112 inMachines; // actually bought
        bool buy;
    }
    address public host;
    address public fomoTokenAddress;
    uint256 public drawingTime; // every 3 minutes announce the result
    mapping(address => Pool) public pools;
    address[] public poolList;
    bytes32 public salt;
    constructor(address _fomoTokenAddress){
        host = msg.sender;
        fomoTokenAddress = _fomoTokenAddress;
        drawingTime = block.timestamp + 180;
    }
    error PoolAlreadyExists();
    error IvalidParamenters();
    event PoolCreated(address indexed poolAddress, uint64 indexed pMachine);
    function createPool(uint64 pMachine) external returns(bool){
        require(pools[msg.sender].numberOfMachines == 0, PoolAlreadyExists());
        Pool memory pool = Pool({
            poolOnwer: msg.sender,
            numberOfMachines: 0,
            priceOfMachine: pMachine,
            totalInMachines: 0,
            buyers: new Buyer[](0)
        });
        pools[msg.sender] = pool;
        poolList.push(msg.sender);
        emit PoolCreated(msg.sender, pMachine);
        return true;
    }
    event RefundFailed(address indexed buyer, uint256 amount);
    error InsufficientFomoToken();
    error TransferFailed();
    function buyMiningMachine(address poolAddress, uint256 nMachines, uint256 fToken) public payable returns (bool){
        Pool storage pool = pools[poolAddress];
        uint256 value = nMachines * pool.priceOfMachine;
        require(fToken >= value, "Insufficient Fomo token.");
        require(IERC20(fomoTokenAddress).balanceOf(msg.sender) >= value, InsufficientFomoToken());
        bool suc = IERC20(fomoTokenAddress).transferFrom(msg.sender, address(this), value);
        require(suc, TransferFailed());
        Buyer memory buyer = Buyer({
            buyerAddress: msg.sender,
            nMachines: uint112(nMachines),
            inMachines: 0,
            buy: true
        });
        pool.buyers.push(buyer);
        return true;
    }
    // returns an array of winning ranges in 0-1,000,000
    // each range corresponds to proportion of total value of each pool to total value of all pools
    // e.g. if there are 3 pools with total values of 100, 200, 700 respectively
    // the ranges array will be [100000, 300000, 1000000]
    // if the winning number is 250,000, the winning pool is the second one
    function calculatePoolWinningRange(uint256 winningNum) internal returns (address, uint256){
        address[] memory pList = poolList;
        uint256[] memory ranges = new uint256[](pList.length);
        if (ranges.length == 0) return (address(0), 0);
        Pool storage pool;
        uint256 preInValue = 0;
        for (uint256 i=0; i < pList.length; i++){
            pool = pools[pList[i]];
            pool.totalInMachines = 0;
            for(uint256 j=0; j<pool.buyers.length; j++){
                if (!pool.buyers[j].buy){
                    pool.buyers[j].inMachines = 0;
                    pool.buyers[j] = pool.buyers[pool.buyers.length - 1];
                    pool.buyers.pop();
                    j--;
                    continue;
                }
                uint256 values = IERC20(fomoTokenAddress).balanceOf(pool.buyers[j].buyerAddress);
                uint256 n = values / uint256(pool.priceOfMachine);
                if (n == 0){
                    pool.buyers[j].inMachines = 0;
                    continue;
                }
                if (n > uint256(pool.buyers[j].nMachines)){
                    n = uint256(pool.buyers[j].nMachines);
                }
                bool suc = IERC20(fomoTokenAddress).transferFrom(
                    pool.buyers[j].buyerAddress, 
                    address(this), 
                    uint256(pool.priceOfMachine) * n);
                if (suc){
                    pool.buyers[j].inMachines = uint112(n);
                    pool.totalInMachines += uint64(n);
                }else{
                    pool.buyers[j].inMachines = 0;
                }
                ranges[i] += uint256(pool.priceOfMachine) * n;
            }
            ranges[i] += preInValue;
            preInValue = ranges[i];
        }
        for (uint256 i=0; i < ranges.length; i++){
            ranges[i] = ranges[i] * 10**6 / ranges[ranges.length - 1];
            if (ranges[i] >= winningNum){
                return (pList[i], ranges[ranges.length - 1]);
            }
        }
        return (address(0), 0);
    }
    error OnlyHost();
    modifier onlyHost(){
        require(msg.sender == host, OnlyHost());
        _;
    }
    // time of setting salt must be at least 3 minutes before drawing time
    function setSalt(bytes32 _salt) external onlyHost {
        salt = _salt;
        drawingTime = block.timestamp + 180;
    }
    error DrawingTimeNotReached();
    modifier afterThreeMinutes(){
        require(block.timestamp >= drawingTime, DrawingTimeNotReached());
        _;
    }
    error InvalidSalt();
    event GenerateWinningPool(address indexed winningPool, uint256 winningNum, uint256 totalReward);
    function getWinningPool(bytes32 rawSalt) external afterThreeMinutes onlyHost returns (address, uint256){
        require(keccak256(abi.encode(rawSalt)) == salt, InvalidSalt());
        uint256 winningNum = uint256(keccak256(abi.encode(rawSalt, block.timestamp))) % 1000000;
        (address winningPool, uint256 totalReward) = calculatePoolWinningRange(winningNum);
        require(winningPool != address(0), "no pools available");
        distributeRewards(winningPool, totalReward);
        emit GenerateWinningPool(winningPool, winningNum, totalReward);
        return (winningPool, totalReward);
    }
    error NoRewardToDistribute();
    function distributeRewards(address winningPool, uint256 totalReward) internal {
        require(totalReward > 0, NoRewardToDistribute());
        Pool memory pool = pools[winningPool];
        bool suc = IERC20(fomoTokenAddress).transferFrom(
            host,
            pool.poolOnwer,
            totalReward / 1000); // 0.1% to pool owner
        if (!suc){
            emit RefundFailed(pool.poolOnwer, totalReward / 1000);
        }
        totalReward = totalReward * 999 / 1000; // 99.9% to buyers
        for (uint256 i=0; i < pool.buyers.length; i++){
            if (pool.buyers[i].inMachines == 0) continue;
            uint256 buyerReward = uint256(pool.buyers[i].inMachines) * totalReward / pool.totalInMachines;
            suc = IERC20(fomoTokenAddress).transfer(pool.buyers[i].buyerAddress, buyerReward);
            if (!suc){
                emit RefundFailed(pool.buyers[i].buyerAddress, buyerReward);
            }
        }
    }
    error InvalidBuyerIndex();
    error NotBuyer();
    function updateBuyerInMachines(address poolAddress, uint256 buyerIndex, uint112 inMachines) external {
        Pool storage pool = pools[poolAddress];
        require(buyerIndex < pool.buyers.length, InvalidBuyerIndex());
        require(msg.sender == pool.buyers[buyerIndex].buyerAddress, NotBuyer());
        pool.buyers[buyerIndex].inMachines = inMachines;
    }
    function updateBuyerBuyStatus(address poolAddress, uint256 buyerIndex, bool buy) external {
        Pool storage pool = pools[poolAddress];
        require(buyerIndex < pool.buyers.length, InvalidBuyerIndex());
        require(msg.sender == pool.buyers[buyerIndex].buyerAddress, NotBuyer());
        pool.buyers[buyerIndex].buy = buy;
    }
}