// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract CalledContract {
    function getTwo() external pure returns(uint8){
        return 2;
    }
}

contract Trycatch{
    CalledContract cc = new CalledContract();
    event SuccessEvent();
    event ReturnDataEvent(bytes);
    event CatchStringEvent(string);
    function trycatch() external returns(uint8){
        try cc.getTwo() returns(uint8 value){
            return value;
        }catch Error(string memory revertReason){   // require(condition, "revertReason"); revert("revertReason");
            emit CatchStringEvent(revertReason);
            return 0;
        }catch(bytes memory returnData){            // any other assert
            emit ReturnDataEvent(returnData);
            return 0;
        }
    }
}

contract Trycatch3{
    CalledContract cc = new CalledContract();
    function trycatch() external view returns(uint8){
        try cc.getTwo() returns(uint8 value){
            return value;
        }catch Error(string memory revertReason){
            return 0;
        }
    }
}

contract Trycatch2{
    CalledContract cc = new CalledContract();
    function trycatch() external view returns(uint8){
        try cc.getTwo() returns(uint8 value){
            return value;
        }
        catch{
            return 0;
        }
    }
}