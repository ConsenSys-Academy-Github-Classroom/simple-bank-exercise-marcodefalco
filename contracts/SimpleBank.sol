pragma solidity >=0.5.16 <0.9.0;

contract SimpleBank {
    /* State variables
     */

    // Fill in the visibility keyword.
    // Hint: We want to protect our users balance from other contracts
    mapping(address => uint256) private balances;

    // Fill in the visibility keyword
    // Hint: We want to create a getter function and allow contracts to be able
    //       to see if a user is enrolled.
    mapping(address => bool) public enrolled;

    // Let's make sure everyone knows who owns the bank, yes, fill in the
    // appropriate visilibility keyword
    address public owner = msg.sender;

    /* Events - publicize actions to external listeners
     */

    // Add an argument for this event, an accountAddress
    event LogEnrolled(address accountAddress);

    // Add 2 arguments for this event, an accountAddress and an amount
    event LogDepositMade(address accountAddress, uint256 amount);

    // Create an event called LogWithdrawal
    // Hint: it should take 3 arguments: an accountAddress, withdrawAmount and a newBalance
    event LogWithdrawal(
        address accountAddress,
        uint256 withdrawAmount,
        uint256 newBalance
    );

    /* Functions
     */

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() public view returns (uint256) {
        // 1. A SPECIAL KEYWORD prevents function from editing state variables;
        //    allows function to run locally/off blockchain (This is 'view' mdf)
        // 2. Get the balance of the sender of this transaction 
        return balances[msg.sender]; // here I'm using the mapping above to point the msg.sender address ot the associated value
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool) {
        // 1. enroll of the sender of this transaction
        if (enrolled[msg.sender]) return false; // if statement is truthy, then return false. this is to avoid re-enrolling the enrolled ones.

        enrolled[msg.sender] = true; // enrolling the senders, basically the requestors of the fucntion
        emit LogEnrolled(msg.sender); // emitting the event to publicize it
        return true;
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable returns (uint256) {
        // 1. Add the appropriate keyword so that this function can receive ether ( PAYABLE)
        // 2. Users should be enrolled before they can make deposits
        // 3. Add the amount to the user's balance. Hint: the amount can be
        //    accessed from of the global variable `msg`
        // 4. Emit the appropriate event associated with this function
        // 5. return the balance of sndr of this transaction
        require(enrolled[msg.sender], "Enroll me please!"); // as per number 2 above: require checks if enrolled, when not, then message.
        uint256 initialBalance = balances[msg.sender]; // pointing at the balance of sender thanks to mapping
        uint256 newBalance = initialBalance + msg.value; // value is the the 'value' in eth and something the user can set (in remix there is appropriate box, I guess it's the transfer box in MetaMask)
        require(newBalance > initialBalance, "Error, you should have more money in the bank than before!"); // checking that the deposit adds to the balance.
        balances[msg.sender] = newBalance; // newBalance is the newBalance associated to the account
        emit LogDepositMade(msg.sender, msg.value); // emitting the appropiate event: who and how much
        return newBalance;
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint256 withdrawAmount) public returns (uint256) {
        // If the sender's balance is at least the amount they want to withdraw,
        // Subtract the amount from the sender's balance, and try to send that amount of ether
        // to the user attempting to withdraw.
        // return the user's balance.
        // 1. Use a require expression to guard/ensure sender has enough funds
        // 2. Transfer Eth to the sender and decrement the withdrawal amount from
        //    sender's balance
        // 3. Emit the appropriate event for this message
        uint256 initialBalance = balances[msg.sender]; // as above: setting the initialBalance to the initial balance of the msg sender
        require(initialBalance >= withdrawAmount, "Not enough funds!"); // checking the user doesn't want to 'overdraw'
        uint256 newBalance = initialBalance - withdrawAmount; // subtracting balance withdrawn
        require(newBalance < initialBalance, "You should have less funds than before!"); // checking it makes sense
        balances[msg.sender] = newBalance; // assigning new balance in the mapping
        msg.sender.transfer(withdrawAmount); // transfering the value to the message sender
        emit LogWithdrawal(msg.sender, withdrawAmount, newBalance); // emit to event
    }
}