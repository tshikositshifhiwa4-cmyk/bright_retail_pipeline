# BrightLearn Data Warehouse Build

A star-schema data warehouse built from a single messy flat-file export, powering inventory, customer retention, and store performance analysis for a fictional 5-store South African retail chain.

![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![SSIS](https://img.shields.io/badge/SSIS-ETL-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![SSMS](https://img.shields.io/badge/SSMS-Management%20Studio-A31515?style=for-the-badge&logo=microsoft&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-Queries-336791?style=for-the-badge&logo=databricks&logoColor=white)
![Status](https://img.shields.io/badge/Status-In%20Progress-facc8f?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-a78bfa?style=for-the-badge)

---

## Overview

BrightLearn operates 5 physical stores across South Africa, each running its own Point-of-Sale (POS) system. Every POS exports sales data as a **single flat file** — transactions, customers, products, and stores all mixed into one unnormalised table, with known data quality issues accumulated over time.

This project builds a functional **star-schema data warehouse** in SQL Server to turn that flat export into a queryable, trustworthy source for business decisions.

| | |
|---|---|
| **Stores** | Sandton, Pretoria (Gauteng) · Cape Town (Western Cape) · Umhlanga (KwaZulu-Natal) · Gqeberha (Eastern Cape) |
| **Loyalty Tiers** | Bronze → Silver → Gold |
| **Goal** | Data-driven decisions on inventory, customer retention & store performance |

---

##  Schema Design

A star schema centered on `fact_sales`, with one deliberate exception:

- **`dim_customer`**
- **`dim_store`** 
- **`dim_product`**, **`dim_supplier`**, **`dim_cashier`**, **`dim_date`**, **`dim_payment`**

### Slowly Changing Dimensions

| Dimension | Attribute | SCD Type | Reasoning |
|---|---|---|---|
| `dim_customer` | `loyalty_tier` | **Type 2** | Preserves tier history so past sales stay attributed to the tier a customer held *at the time* |
| `dim_store` | `store_manager` | **Type 2** | Preserves manager history so historical sales remain associated with the manager responsible for the store at the time of each transaction. |
| All other dimensions | — | **Type 1** | No business need to track history; overwrite on change |

<img width="1600" height="1344" alt="star_schema" src="https://github.com/user-attachments/assets/aa0cdf24-8dbe-4c59-8cbd-1f3cfd7d52ad" />


---

##  ETL Pipeline (SSIS)
1. **Load** — raw flat file lands untouched in a staging table
2. **Schema** — staging data is split into dimension and fact tables
3. **Clean** — data type fixes, null handling, formatting standardisation
4. **Query** — the clean warehouse answers real business questions

---

##  Data Quality Issues Handled

| Column | Issue | Fix |
|---|---|---|
| `transaction_date` | Inconsistent date format | Standardised to `DATE` |
| `transaction_amount`, `transaction_discount`, `unit_price`, `cost_price` | Stored as text | Cast to numeric |
| `customer_email` | Blank rows | Substituted placeholder during staging |
| `customer_phone` | 9-digit numbers missing leading `0` (SA format) | Padded to 10 digits, kept as `VARCHAR` (not `INT`, to preserve leading zero) |

---

## Key Business Logic

```sql
-- Line amount (with optional line-level discount)
Line_Amount = Unit_Price × Quantity × (1 − Discount%)

-- Items needing reorder vs. overdue for restock
WHERE Stock_On_Hand <= Reorder_Threshold

-- Profit
Profit = Revenue − (Cost_Price × Quantity)
```

---

## Tech Stack

- **SQL Server** — warehouse engine
- **SSMS** — development & querying
- **SSIS** — ETL orchestration
- **T-SQL** — schema, transforms, business queries
- **GitHub** — version control

---

## Assessment Weighting

| Component | Weight |
|---|---|
| SSIS ETL | 30% |
| Queries | 25% |
| Database Design (Schema & Normalisation) | 20% |
| Data Quality | 15% |
| GitHub | 5% |
| Code Quality | 5% |

---

## Lessons Learned

- Started with `dim_customer` → `dim_customer_location` split; a join on city/province caused row-count explosion (~2M rows from a source of a few thousand). Flattened back into a single `dim_customer` table — cardinality didn't justify the snowflake, and it removed the bug entirely.
- `ROW_NUMBER()` must be applied *after* deduplication, not before — applying it inline with `DISTINCT` silently fails to dedupe anything.
- All idempotent load scripts use `OBJECT_ID(...) IS NULL` for table creation and `WHERE NOT EXISTS` for inserts, so the pipeline can be re-run safely without errors or duplicates.

---

## 👤 Author

**Tshifhiwa Tshikosi**

Business Intellegence, Data Analyst & Junior Data Engineer

---
