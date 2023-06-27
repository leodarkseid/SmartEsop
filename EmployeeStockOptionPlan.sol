// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/security/ReentrancyGuard.sol";


/**
 * @title EmployeeStockOptionPlan
 * @dev A contract for managing stock option grants and vesting schedules for employees.
 */

contract EmployeeStockOptionPlan is Ownable, ReentrancyGuard {

    uint256 constant INFINITY = 2**256 - 1;

    struct Employee {
        uint256 stockOptions;
        uint256 vestingSchedule;
    } 
    mapping(address => Employee) public employee;
    mapping(address => uint256) private excercisedBalance;
    mapping(address => uint256) private vestingBalance;



    /**
     * @dev Adds a new employee to the plan.
     * @param _employeeAddress The address of the employee.
     */
    function addEmployee(address _employeeAddress) public onlyOwner nonReentrant {
        employee[_employeeAddress] = Employee(
            0,
            0
        );
    }

    /**
     * @dev Grants stock options to an employee.
     * @param _employeeAddress The address of the employee.
     * @param _stockOptions The number of stock options to grant.
     */

    function grantStockOptions(address _employeeAddress, uint256 _stockOptions) public onlyOwner nonReentrant {
        require(_employeeAddress != address(0) , "Invalid employee address");

        
        employee[_employeeAddress].stockOptions += _stockOptions;
        if (employee[_employeeAddress].vestingSchedule == 0){employee[_employeeAddress].vestingSchedule = INFINITY;}

        emit StockOptionsGranted(_employeeAddress, _stockOptions);
    }

    /**
     * @dev Sets the vesting schedule for an employee.
     * @param _employeeAddress The address of the employee.
     * @param _vestingSchedule The timestamp representing the vesting schedule.
     */

    function setVestingSchedule(address _employeeAddress, uint256 _vestingSchedule) public onlyOwner nonReentrant{
        require(_vestingSchedule > block.timestamp, "vesting schedule must be in the future");
        require(employee[_employeeAddress].stockOptions > 0,"Employee doesn't exist");

        if (employee[msg.sender].stockOptions > 0) {_vest(msg.sender);}
        employee[_employeeAddress].vestingSchedule = _vestingSchedule;
        }

    /**
     * @dev Gets the current block timestamp.
     * @return The current block timestamp.
     */
    function getBlockTimeStamp() public view returns(uint256){
        return block.timestamp;
    }

    /**
     * @dev Calculates the remaining time until vesting for an employee.
     * @param _employeeAddress The address of the employee.
     * @return The remaining time until vesting in seconds.
     */

    function vestingCountdown(address _employeeAddress)public view returns(uint256){
        require(employee[_employeeAddress].stockOptions > 0,"Employee doesn't exist");
        return (employee[_employeeAddress].vestingSchedule - block.timestamp) > 0 ?
        (employee[_employeeAddress].vestingSchedule - block.timestamp):0
        ;
    }

    /**
     * @dev Performs the vesting process for an employee.
     * @param _employeeAddress The address of the employee.
     */

    function _vest(address _employeeAddress) internal {
        require(employee[_employeeAddress].vestingSchedule != INFINITY, "Vesting schedule is yet to be set");
        
        if (block.timestamp > employee[_employeeAddress].vestingSchedule){
            vestingBalance[_employeeAddress] += employee[_employeeAddress].stockOptions;
            employee[msg.sender].stockOptions -= employee[_employeeAddress].stockOptions;
            employee[msg.sender].vestingSchedule -= employee[_employeeAddress].vestingSchedule;
        }
    }

    /**
     * @dev Performs the vesting process for the calling employee.
     */

    function vestOptions() public nonReentrant{
        require(employee[msg.sender].stockOptions > 0, "This user does not exists or This Employee does not have stock options");
        _vest(msg.sender);
    }

    /**
     * @dev Exercises vested stock options for the calling employee.
     */

    function exerciseOptions() public nonReentrant{
        require(vestingBalance[msg.sender] > 0 ,"Employee vesting Balance is less than zero or employee doesn't exist");

        
        excercisedBalance[msg.sender] += vestingBalance[msg.sender];
        vestingBalance[msg.sender] -= vestingBalance[msg.sender];
        emit stockOptionsExcercised(msg.sender);
    }

    /**
     * @dev Gets the number of vested options for an employee.
     * @param _employeeAddress The address of the employee.
     * @return The number of vested options.
     */

    function getVestedOptions(address _employeeAddress) public view returns(uint256){
        return vestingBalance[_employeeAddress];
    }

     /**
     * @dev Gets the number of exercised options for an employee.
     * @param _employeeAddress The address of the employee.
     * @return The number of exercised options.
     */

    function getExcercisedOptions(address _employeeAddress) public view returns(uint256){
        return excercisedBalance[_employeeAddress];
    }

    /**
     * @dev Transfers vested stock options from the calling employee to a recipient.
     * @param _recipient The address of the recipient.
     * @param _stockOptionsAmount The number of stock options to transfer.
     */


    function transferOptions(address _recipient, uint256 _stockOptionsAmount)public nonReentrant {
        require(_stockOptionsAmount > 0, "stock options must be greater than zero");
        require(employee[_recipient].stockOptions > 0 || vestingBalance[_recipient] > 0, "Employee does not exist");
        require(_stockOptionsAmount <= vestingBalance[msg.sender], "Employee has insufficient vesting balance");


        vestingBalance[msg.sender] -= _stockOptionsAmount;
        vestingBalance[_recipient] += _stockOptionsAmount;

        emit StockOptionsGranted(_recipient, _stockOptionsAmount);
    }

    event StockOptionsGranted(address employee, uint256 stockOptionsAmount);
    event StockOptionsTransferred(address recpient, uint256 stockOptionAmount);
    event stockOptionsExcercised(address recipient);

}
