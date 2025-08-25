package com.example.bank.service;

import com.example.bank.model.Account;
import com.example.bank.model.AuditLog;
import com.example.bank.model.Transaction;
import com.example.bank.model.TransferResult;
import com.example.bank.repository.AccountRepository;
import com.example.bank.repository.AuditLogRepository;
import com.example.bank.repository.TransactionRepository;
import org.springframework.dao.OptimisticLockingFailureException;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;

import java.math.BigDecimal;
import java.util.*;

@Service
public class TransferService {
    
    // Repositories to access database entities
    private final AccountRepository accountRepo;
    private final TransactionRepository txRepo;
    private final AuditLogRepository auditRepo;
    
    // Transaction manager for programmatic transaction handling
    private final PlatformTransactionManager txManager;
    
    // Constructor that injects necessary dependencies
    public TransferService(AccountRepository accountRepo, 
                         TransactionRepository txRepo, 
                         AuditLogRepository auditRepo, 
                         PlatformTransactionManager txManager) {
        this.accountRepo = accountRepo;
        this.txRepo = txRepo;
        this.auditRepo = auditRepo;
        this.txManager = txManager;
    }
    
    /**
     * Main method to transfer funds between accounts
     * Choose best isolation type: Isolation.SERIALIZABLE, Isolation.REPEATABLE_READ, Isolation.READ_COMMITTED
	 * to guarantee total consistency
     * and pessimistic locking to avoid race conditions
     */
    @Transactional(isolation = Isolation.READ_UNCOMMITTED)
    public TransferResult transferFunds(String fromAccountNum, String toAccountNum, BigDecimal amount) {
        // Parameter validation: ensures they are not null
        Objects.requireNonNull(fromAccountNum);
        Objects.requireNonNull(toAccountNum);
        Objects.requireNonNull(amount);
        
        // Business validation: amount must be positive

		

        // Find accounts by number and get their IDs
        // If they don't exist, throw exception (this should be handled better in production)
        Long fromId = 0L;
        Long toId = 0L;
        
        // ANTI-DEADLOCK STRATEGY: Sort IDs to always lock in the same order
        // This prevents two transfers from blocking each other
        List<Long> ids = new ArrayList<>();
        // Sort in ascending order

        // PESSIMISTIC LOCKING: Get accounts with exclusive lock
        // The lockByIds method uses @Lock(PESSIMISTIC_WRITE) to lock the rows
        List<Account> locked = null; //change this
        
        // Map locked accounts to from and to variables
        // Since accounts are ordered by ID, we need to map them correctly
        Account from = locked.get(0).getId().equals(fromId) ? locked.get(0) : locked.get(1);
        Account to = locked.get(0).getId().equals(toId) ? locked.get(0) : locked.get(1);
        
        // BALANCE VALIDATION: Check that source account has sufficient funds, if not, create audit log for failed transfer
		// and return failure result
        
        
        // If the balance is ok, CREATE TRANSACTION: Record the start of the transfer
        // The "started" status indicates the transfer is in progress
        
        
        // UPDATE BALANCES: Perform the mathematical transfer
        // from.balance = from.balance - amount
        // to.balance = to.balance + amount
        
        
        // PERSIST CHANGES: Save updated accounts
        // Spring Data JPA will detect changes and persist them
        
        // FINALIZE TRANSACTION: Mark as completed
        
        
        // SUCCESSFUL AUDIT: Record the success of the transfer
        // Use simple string format for easier debugging
        
        
        // Return successful result with account information
        //return TransferResult.ok(tx.getId(), from.getBalance(), to.getBalance());
		return null;
    }
    
    /**
     * High-level method that handles automatic retries
     * Useful for handling optimistic locking conflicts
     */
    public TransferResult transferWithRetry(String from, String to, BigDecimal amount, int maxRetries) {
        int attempts = 0;
        
        // RETRY LOOP: Try until maximum retries are reached
        while (true) {
            // CONFIGURE PROGRAMMATIC TRANSACTION: Create transaction definition
            DefaultTransactionDefinition def = new DefaultTransactionDefinition();
            def.setIsolationLevel(TransactionDefinition.ISOLATION_SERIALIZABLE); // Same isolation level
            def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRED); // Require existing transaction or create new one
            
            // START TRANSACTION: Get transaction status
            TransactionStatus status = txManager.getTransaction(def);
            
            try {
                // ATTEMPT TRANSFER: Call the main method
                TransferResult res = transferFunds(from, to, amount);
                
                // SUCCESS: Commit the transaction
                txManager.commit(status);
                return res;
                
            } catch (OptimisticLockingFailureException e) {
                // OPTIMISTIC CONFLICT: Another transaction modified the data
                // Rollback and retry if limit not reached
                txManager.rollback(status);
                if (attempts++ < maxRetries) {
                    continue; // Retry
                }
                // Limit reached, return error
                return TransferResult.fail(TransferResult.Status.CONFLICT_RETRY, "optimistic conflict after retries");
                
            } catch (DataAccessException e) {
                // DATABASE ERROR: Technical problem (connection, constraint, etc.)
                txManager.rollback(status);
                if (attempts++ < maxRetries) {
                    continue; // Retry
                }
                return TransferResult.fail(TransferResult.Status.ERROR, "db error: " + e.getMessage());
                
            } catch (RuntimeException e) {
                // NON-RECOVERABLE ERROR: Logic or validation error
                // Don't retry, propagate the error
                txManager.rollback(status);
                throw e;
            }
        }
    }
}
