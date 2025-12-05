// SPDX-License-Identifier:GPL-3.0
pragma solidity ^0.8.17;

contract Fomo{
    struct Pool{
        uint64 numberOfMachines;
        uint64 priceOfMachine;
        uint64 startValue;
        uint64 sold;
        uint256 totalInvestment;
        Buyer[] buyers;
    }
    struct Buyer{
        address buyerAddress;
        uint256 nMachines;
    }
    address public host;
    mapping(address => Pool) public pools;
    constructor(){
        host = msg.sender;
    }
    error PoolAlreadyExists();
    error IvalidParamenters();
    event PoolCreated(address indexed poolAddress, uint64 indexed nMachines, uint64 indexed pMachine, uint64 sValue);
    function createPool(uint64 nMachines, uint64 pMachine, uint64 sValue) external returns(bool){
        require(nMachines > 0 && pMachine >0 && sValue > 0 && nMachines * pMachine >= sValue, IvalidParamenters());
        require(pools[msg.sender].numberOfMachines == 0, PoolAlreadyExists());
        Pool memory pool = Pool({
            numberOfMachines: nMachines,
            priceOfMachine: pMachine,
            startValue: sValue,
            sold: 0,
            totalInvestment: 0,
            buyers: new Buyer[](0)
        });
        pools[msg.sender] = pool;
        emit PoolCreated(msg.sender, nMachines, pMachine, sValue);
        return true;
    }
    error NoEnoughMachines();
    event RefundFailed(address indexed buyer, uint256 amount);
    function buyMiningMachine(address poolAddress, uint256 nMachines) public payable returns (bool){
        Pool storage pool = pools[poolAddress];
        require(pool.numberOfMachines - pool.sold> nMachines, NoEnoughMachines());
        require(msg.value > nMachines * pool.priceOfMachine, "Insufficient payment.");
        Buyer memory buyer = Buyer({
            buyerAddress: msg.sender,
            nMachines: nMachines
        });
        pool.buyers.push(buyer);
        pool.sold += uint64(nMachines);
        if (msg.value > pool.priceOfMachine * nMachines){
            bool suc = payable(msg.sender).send(msg.value - pool.priceOfMachine * nMachines);
            if (!suc){
                emit RefundFailed(msg.sender, msg.value - pool.priceOfMachine * nMachines);
            }
        }
        return true;
    }
}