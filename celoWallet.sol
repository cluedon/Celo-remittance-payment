// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrossBorderPayments {
    struct Transaction {
        address sender;
        address payable recipient; // Updated data type to address payable
        uint amount;
        bool isRemittance;
        bool isCompleted;
    }

    mapping(uint => Transaction) public transactions;
    uint public transactionCount;

    event PaymentSent(uint transactionId, address sender, address payable recipient, uint amount, bool isRemittance);
    event PaymentReceived(uint transactionId, address sender, address payable recipient, uint amount, bool isRemittance);
    event PaymentCompleted(uint transactionId, address sender, address payable recipient, uint amount, bool isRemittance);

    function sendPayment(address payable _recipient, bool _isRemittance) external payable {
        require(msg.value > 0, "Invalid payment amount");
        uint transactionId = transactionCount;
        transactions[transactionId] = Transaction(msg.sender, _recipient, msg.value, _isRemittance, false);
        transactionCount++;
        emit PaymentSent(transactionId, msg.sender, _recipient, msg.value, _isRemittance);
    }

    function receivePayment(uint _transactionId) external {
        require(_transactionId < transactionCount, "Invalid transaction ID");
        Transaction storage transaction = transactions[_transactionId];
        require(!transaction.isCompleted, "Transaction is already completed");
        require(transaction.recipient == msg.sender, "Unauthorized recipient");
        transaction.recipient.transfer(transaction.amount);
        transaction.isCompleted = true;
        emit PaymentReceived(_transactionId, transaction.sender, transaction.recipient, transaction.amount, transaction.isRemittance);
        emit PaymentCompleted(_transactionId, transaction.sender, transaction.recipient, transaction.amount, transaction.isRemittance);
    }
}
