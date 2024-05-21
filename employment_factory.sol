// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EmploymentContract.sol";

contract EmploymentFactory {
    // 记录所有雇佣合约地址
    EmploymentContract[] public contracts;
    // 雇主到雇员的映射
    mapping(address => address[]) public employerToEmployees;
    // 雇员到雇主的映射
    mapping(address => address) public employeeToEmployer;

    event ContractCreated(address contractAddress, address employer, address employee);

    // 创建雇佣合约的函数
    function createContract(address _employee, uint _monthlySalary, uint _annualBonus, uint _penaltyAmount, address _paymentToken) public {
        EmploymentContract newContract = new EmploymentContract(msg.sender, _employee, _monthlySalary, _annualBonus, _penaltyAmount, _paymentToken);
        contracts.push(newContract);
        employerToEmployees[msg.sender].push(_employee);
        employeeToEmployer[_employee] = msg.sender;
        emit ContractCreated(address(newContract), msg.sender, _employee);
    }

    // 查询雇主门下的雇员
    function getEmployeesByEmployer(address _employer) public view returns (address[] memory) {
        return employerToEmployees[_employer];
    }

    // 查询雇员属于哪个雇主
    function getEmployerByEmployee(address _employee) public view returns (address) {
        return employeeToEmployer[_employee];
    }

    // 获取所有雇佣合约地址
    function getAllContracts() public view returns (EmploymentContract[] memory) {
        return contracts;
    }
}
