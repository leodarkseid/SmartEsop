# Employee Stock Option Plan

This smart contract is an Employee Stock Option Plan implemented in Solidity. It allows for the management and granting of stock options to employees. The contract is designed to be owned by an address and provides various functions for adding employees, granting stock options, setting vesting schedules, and managing vested and exercised options.

## Contract Details

The contract inherits from the `Ownable` and `ReentrancyGuard` contracts provided by the OpenZeppelin library. It includes the following features:

### Structs

- `Employee`: Represents an employee and contains the following fields:
  - `stockOptions`: The number of stock options granted to the employee.
  - `vestingSchedule`: The vesting schedule for the employee's stock options.

### Storage

The contract uses the following mappings for storage:

- `employee`: Maps employee addresses to their corresponding `Employee` struct, allowing retrieval of employee information.
- `excercisedBalance`: Maps employee addresses to the balance of exercised stock options.
- `vestingBalance`: Maps employee addresses to the balance of vested stock options.

### Functions

The contract provides the following functions:

- `addEmployee(address _employeeAddress)`: Adds an employee to the contract by initializing their `Employee` struct with default values.
- `grantStockOptions(address _employeeAddress, uint256 _stockOptions)`: Grants stock options to an employee by increasing their `stockOptions` field. If the employee's vesting schedule is not set, it is set to infinity.
- `setVestingSchedule(address _employeeAddress, uint256 _vestingSchedule)`: Sets the vesting schedule for an employee. The vesting schedule must be in the future, and the employee must exist.
- `getBlockTimeStamp()`: Returns the current block timestamp.
- `vestingCountdown(address _employeeAddress)`: Returns the remaining time until vesting for an employee's stock options. If the vesting schedule has already passed, it returns 0.
- `_vest(address _employeeAddress)`: Internal function used to vest the employee's stock options based on the current time.
- `vestOptions()`: Vests the stock options for the calling employee. Requires that the employee exists and has stock options.
- `exerciseOptions()`: Exercises the vested stock options for the calling employee.
- `getVestedOptions(address _employeeAddress)`: Returns the balance of vested stock options for an employee.
- `getExcercisedOptions(address _employeeAddress)`: Returns the balance of exercised stock options for an employee.
- `transferOptions(address _recipient, uint256 _stockOptionsAmount)`: Transfers vested stock options from the calling employee to the recipient address. Requires that the stock option amount is greater than zero, the employee exists, and the employee has sufficient vested balance.

### Events

The contract emits the following event:

- `StockOptionsGranted(address employee, uint256 stockOptionsAmount)`: Indicates when stock options are granted to an employee, providing the employee's address and the granted amount.
- `event StockOptionsTransferred(address recpient, uint256 stockOptionAmount)`;
- `event stockOptionsExcercised(address recipient)`;

## Getting Started

To use this contract, you can deploy it to an Ethereum network or interact with it through a compatible blockchain interface such as Remix, Truffle, or Hardhat.

