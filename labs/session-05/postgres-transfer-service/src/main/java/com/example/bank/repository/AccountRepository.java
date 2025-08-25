package com.example.bank.repository;

import com.example.bank.model.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import jakarta.persistence.LockModeType;
import java.util.List;
import java.util.Optional;

@Repository
public interface AccountRepository extends JpaRepository<Account, Long> {
    
    /**
     * Find account by account number
     * Returns Optional to handle cases where account doesn't exist
     */
    Optional<Account> findByAccountNumber(String accountNumber);
    
    /**
     * CRITICAL: Pessimistic locking to prevent race conditions during transfers
     * 
     * Why PESSIMISTIC_WRITE?
     * 1. EXCLUSIVE ACCESS: Locks the database row exclusively, preventing other transactions
     *    from reading or modifying the account data
     * 2. RACE CONDITION PREVENTION: Ensures that when we check balance and update it,
     *    no other transaction can interfere between the check and update
     * 3. CONSISTENCY: Guarantees that the balance we read is the same balance we update
     * 4. DEADLOCK AVOIDANCE: Combined with ID ordering in TransferService, prevents
     *    circular waiting between multiple transfer operations
     * 
     * Alternative approaches considered:
     * - OPTIMISTIC locking (@Version): Would require retry logic and could fail under high concurrency
     * - PESSIMISTIC_READ: Would allow other transactions to read but not write, but we need exclusive access
     * - No locking: Would lead to race conditions where two transfers could both read the same balance
     * 
     * Performance impact:
     * - Slightly slower than no locking due to database-level row locks
     * - But provides absolute consistency guarantees
     * - Essential for financial applications where data integrity is critical
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select a from Account a where a.id in :ids order by a.id asc")
    List<Account> lockByIds(@Param("ids") List<Long> ids);
}
