# Museum Management Database

A PostgreSQL database that centralizes the daily operations of a museum: exhibitions, collection items, staff assignments, storage inventory and visitor transactions.

## The problem
Museums often track exhibitions, item locations, staff and attendance in separate, manual systems. That makes it hard to know where an item is stored, who works on which exhibition, or which exhibitions attract visitors. This project replaces that with one structured database.

## What's inside
- **8 tables:** Exhibition, Employee, Visitor, Inventory, CollectionItem, Transaction, and two linking tables (ExhibitionEmployee, ExhibitionItem) for many-to-many relationships.
- **Data integrity:** primary and foreign keys, unique emails, and check constraints (for example, the number of items in storage can never exceed its capacity, and item types must be from a valid list).
- **Sample data:** inserted with scripts that can be re-run without creating duplicates.
- **Functions:** `update_employee` to change employee details and `add_transaction` to record a visitor purchase by email and exhibition name.
- **Analytics view:** `analytics_recent_quarter` shows transactions, revenue and unique visitors for the latest quarter.
- **Access control:** a read-only role (`manager_read_only`) for managers who need to view data but not change it.

## ER diagram
<img width="1901" height="1151" alt="Museum_LogicalModel drawio" src="https://github.com/user-attachments/assets/5ac69585-0bef-4911-866c-201f71b5a832" />

## How to run
1. Create the database:
```sql
   CREATE DATABASE museum;
```
2. Connect to it (in `psql`: `\c museum`).
3. Run the rest of `museum_db.sql`, starting from `CREATE SCHEMA museumschema;`.

## Example queries
```sql
-- Revenue per exhibition
SELECT e.Name, SUM(t.Amount) AS revenue
FROM museumschema.Transaction t
JOIN museumschema.Exhibition e ON e.ExhibitionID = t.ExhibitionID
GROUP BY e.Name;

-- Latest quarter overview
SELECT * FROM museumschema.analytics_recent_quarter;
```

## Tech
PostgreSQL, PL/pgSQL

## Author
Lilit Babakhanyan
