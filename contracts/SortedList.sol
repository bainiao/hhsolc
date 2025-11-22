// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract SortedList{
    mapping(address => uint8) private scores;
    mapping(address => address) private students;
    uint16 private size;
    address constant GUARD = address(1);
    constructor(){
        students[GUARD] = GUARD;
    }
    function add(address student, uint8 score) external{
        require(students[student] == address(0), "Student already exists");
        address pre = GUARD;
        while(students[pre] != GUARD && scores[students[pre]] > score){
            pre = students[pre];
        }
        students[student] = students[pre];
        students[pre] = student;
        scores[student] = score;
        size++;
    }
    function remove(address student) external{
        require(students[student] != address(0), "student does not exist");
        address pre = GUARD;
        while(students[pre] != GUARD && students[pre] != student){
            pre = students[pre];
        }
        students[pre] = students[student];
        delete students[student];
        delete scores[student];
        size--;
    }
    function getScore(address student) external view returns(uint8){
        return scores[student];
    }
    function increaseScore(address student, uint8 amount) external{

    }
    function reduceScore(address student, uint8 amount) external{

    }
    function getTop(uint16 index) external view returns(address[] memory){
    }
}