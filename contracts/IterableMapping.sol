// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract IterableMapping{
    mapping(address => address) students;
    address constant GUARD = address(1);
    uint16 private listSize = 0;
    constructor(){
        students[GUARD] = GUARD;
    }
    function add(address student) public{
        require(student != address(0), "Invalid address");
        require(student != GUARD, "Invalid address");
        require(students[student] == address(0), "Student already exists");
        students[student] = students[GUARD];
        students[GUARD] = student;
        listSize++;
    }
    function remove(address preStudent, address student) public{
        require(student != address(0), "Invalid address");
        require(student != GUARD, "Invalid address");
        require(students[student] != address(0), "Student does not exist");
        students[preStudent] = students[student];
        students[student] = address(0);
        listSize--;
    }
    function isStudent(address student) public view returns(bool){
        return students[student] != address(0);
    }
    function getStudentList() public view returns(address[] memory){
        address[] memory studentList = new address[](listSize);
        address current = students[GUARD];
        for(uint16 i=0;i<listSize;i++){
            studentList[i] = current;
            current = students[current];
        }
    }
}