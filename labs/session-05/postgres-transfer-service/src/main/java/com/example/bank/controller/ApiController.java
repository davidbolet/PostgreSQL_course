package com.example.bank.controller;

import com.example.bank.model.Account;
import com.example.bank.model.TransferResult;
import com.example.bank.repository.AccountRepository;
import com.example.bank.service.TransferService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {
    
    private final TransferService svc;
    private final AccountRepository accounts;
    
    public ApiController(TransferService svc, AccountRepository accounts) {
        this.svc = svc;
        this.accounts = accounts;
    }
    
    @PostMapping("/seed")
    public ResponseEntity<?> seed() {
        if (!accounts.findByAccountNumber("A-001").isPresent()) {
            Account a = new Account("A-001", new BigDecimal("100.00"));
            a.setVersion(0L);
            accounts.save(a);
        }
        
        if (!accounts.findByAccountNumber("A-002").isPresent()) {
            Account b = new Account("A-002", new BigDecimal("50.00"));
            b.setVersion(0L);
            accounts.save(b);
        }
        
        Map<String, Object> response = new HashMap<>();
        response.put("ok", true);
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/transfer")
    public ResponseEntity<?> transfer(@RequestParam("from") String from, 
                                   @RequestParam("to") String to, 
                                   @RequestParam("amount") String strAmount) {
        BigDecimal amount = new BigDecimal(strAmount);
        TransferResult r = svc.transferWithRetry(from, to, amount, 3);
        Map<String, Object> response = new HashMap<>();
        response.put("status", r.getStatus().name());
        response.put("message", r.getMessage());
        response.put("txId", r.getTxId());
        return ResponseEntity.ok(response);
    }
}
