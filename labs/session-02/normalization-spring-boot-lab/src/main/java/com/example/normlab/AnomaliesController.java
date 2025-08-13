package com.example.normlab;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class AnomaliesController {

    private final JdbcTemplate jdbc;

    public AnomaliesController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/api/anomalies/1nf")
    public Map<String, Object> oneNf() {
        Map<String, Object> out = new HashMap<>();
        try {
            Integer orders = jdbc.queryForObject("SELECT COUNT(*) FROM lab.orders_flat", Integer.class);
            Integer items = jdbc.queryForObject("SELECT COALESCE(SUM(jsonb_array_length(items)),0) FROM lab.orders_flat", Integer.class);
            List<Map<String,Object>> badPhones = jdbc.queryForList(
                "SELECT customer_id, name, phones FROM lab.customers_bad WHERE phones ~ '[,;]'"
            );
            out.put("orders_count", orders);
            out.put("total_items_in_arrays", items);
            out.put("phones_non_atomic_examples", badPhones);
            out.put("hint", "Split items to order_items; split phones to customer_phones with one row per phone");
        } catch (Exception e) {
            out.put("error", e.getMessage());
            out.put("hint", "Did you run sql/01_seed_denormalized.sql against your database? See GUIDE.md");
        }
        return out;
    }

    @GetMapping("/api/anomalies/2nf")
    public Map<String, Object> twoNf() {
        Map<String, Object> out = new HashMap<>();
        try {
            List<Map<String,Object>> partial = jdbc.queryForList(
                "SELECT product_id, COUNT(DISTINCT product_name) AS name_variants, " +
                "COUNT(DISTINCT unit_price) AS price_variants " +
                "FROM lab.order_items_denorm GROUP BY product_id " +
                "HAVING COUNT(DISTINCT product_name) > 1 OR COUNT(DISTINCT unit_price) > 1"
            );
            out.put("partial_dependency_flags", partial);
            out.put("hint", "Move product_name/unit_price to products(product_id PK) and reference from order_items");
        } catch (Exception e) {
            out.put("error", e.getMessage());
            out.put("hint", "Ensure seed SQL has been executed");
        }
        return out;
    }

    @GetMapping("/api/anomalies/3nf")
    public Map<String, Object> threeNf() {
        Map<String, Object> out = new HashMap<>();
        try {
            List<Map<String,Object>> locVariants = jdbc.queryForList(
                "SELECT location_id, array_agg(DISTINCT location_name) AS names " +
                "FROM lab.employees_denorm GROUP BY location_id HAVING COUNT(DISTINCT location_name) > 1"
            );
            List<Map<String,Object>> deptVariants = jdbc.queryForList(
                "SELECT dept_id, array_agg(DISTINCT dept_name) AS names " +
                "FROM lab.employees_denorm GROUP BY dept_id HAVING COUNT(DISTINCT dept_name) > 1"
            );
            out.put("location_name_variants", locVariants);
            out.put("dept_name_variants", deptVariants);
            out.put("hint", "Extract locations(location_id→location_name) and departments(dept_id→dept_name,location_id); employees references dept only");
        } catch (Exception e) {
            out.put("error", e.getMessage());
            out.put("hint", "Ensure seed SQL has been executed");
        }
        return out;
    }
}
