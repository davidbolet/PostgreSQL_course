package com.example.bank.model;

import java.math.BigDecimal;

public class TransferResult {
    
    public enum Status {
        OK, INSUFFICIENT_FUNDS, CONFLICT_RETRY, ERROR
    }
    
    private final Status status;
    private final String message;
    private final Long txId;
    private final BigDecimal fromBalance;
    private final BigDecimal toBalance;
    
    public TransferResult(Status status, String message, Long txId, BigDecimal fromBalance, BigDecimal toBalance) {
        this.status = status;
        this.message = message;
        this.txId = txId;
        this.fromBalance = fromBalance;
        this.toBalance = toBalance;
    }
    
    public static TransferResult ok(Long txId, BigDecimal fromBal, BigDecimal toBal) {
        return new TransferResult(Status.OK, "committed", txId, fromBal, toBal);
    }
    
    public static TransferResult fail(Status status, String message) {
        return new TransferResult(status, message, null, null, null);
    }
    
    // Getters
    public Status getStatus() {
        return status;
    }
    
    public String getMessage() {
        return message;
    }
    
    public Long getTxId() {
        return txId;
    }
    
    public BigDecimal getFromBalance() {
        return fromBalance;
    }
    
    public BigDecimal getToBalance() {
        return toBalance;
    }
}
