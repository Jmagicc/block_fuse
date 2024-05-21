// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EmploymentContract {
    address public employer;
    address public employee;
    uint public employmentPeriod = 2 years;
    uint public monthlySalary;
    uint public annualBonus;
    uint public penaltyAmount;
    uint public contractEnd;
    IERC20 public paymentToken;

    bool public employed = false;
    uint public lastSalaryWithdrawalTime; // 上次领工资的时间

    event Hired(address employee);
    event Fired(address employee);
    event Resigned(address employee);
    event SalaryWithdrawn(address employee);
    event AnnualBonusWithdrawn(address employee);

    constructor(address _employer, address _employee, uint _monthlySalary, uint _annualBonus, uint _penaltyAmount, address _paymentToken) {
        require(_monthlySalary > 0, "Monthly salary must be greater than 0.");
        require(_annualBonus >= 0, "Annual bonus cannot be negative.");
        require(_penaltyAmount >= 0, "Penalty amount cannot be negative.");
        employer = _employer;
        employee = _employee;
        monthlySalary = _monthlySalary;
        annualBonus = _annualBonus;
        penaltyAmount = _penaltyAmount;
        paymentToken = IERC20(_paymentToken);
    }
    // 雇佣函数
    function hire() public {
        require(msg.sender == employer, "Only employer can hire.");
        require(!employed, "Already employed.");
        employed = true;
        contractEnd = block.timestamp + employmentPeriod;
        lastSalaryWithdrawalTime = block.timestamp;

        uint totalCost = employmentPeriod / 30 days * monthlySalary + annualBonus + penaltyAmount;
        require(paymentToken.transferFrom(employer, address(this), totalCost), "Transfer failed.");

        emit Hired(employee);
    }

    // 解雇函数
    function fire() public {
        require(msg.sender == employer, "Only employer can fire.");
        require(employed, "Not employed.");
        employed = false;

        uint workedTime = block.timestamp - lastSalaryWithdrawalTime;
        uint workedMonths = workedTime / 30 days;
        uint compensation = workedMonths * monthlySalary + penaltyAmount;
        require(paymentToken.transfer(employee, compensation), "Transfer failed.");
        require(paymentToken.transfer(employer, paymentToken.balanceOf(address(this))), "Refund failed.");

        emit Fired(employee);
    }

    // 离职函数
    function resign() public {
        require(msg.sender == employee, "Only employee can resign.");
        require(employed, "Not employed.");
        employed = false;

        uint workedTime = block.timestamp - lastSalaryWithdrawalTime;
        uint workedMonths = workedTime / 30 days;
        uint compensation = workedMonths * monthlySalary;
        require(paymentToken.transfer(employee, compensation), "Transfer failed.");
        require(paymentToken.transfer(employer, paymentToken.balanceOf(address(this))), "Refund failed.");

        emit Resigned(employee);
    }

    // 领取工资函数
    function withdrawSalary() public {
        require(msg.sender == employee, "Only employee can withdraw salary.");
        require(employed, "Not employed.");
        require(block.timestamp >= lastSalaryWithdrawalTime + 30 days, "Salary can only be withdrawn monthly.");

        lastSalaryWithdrawalTime += 30 days;
        require(paymentToken.transfer(employee, monthlySalary), "Transfer failed.");

        emit SalaryWithdrawn(employee);
    }

    // 领取年终奖函数
    function withdrawAnnualBonus() public {
        require(msg.sender == employee, "Only employee can withdraw annual bonus.");
        require(employed, "Not employed.");
        require(block.timestamp >= contractEnd, "Annual bonus can only be withdrawn after contract ends.");

        require(paymentToken.transfer(employee, annualBonus), "Transfer failed.");

        emit AnnualBonusWithdrawn(employee);
    }
}
