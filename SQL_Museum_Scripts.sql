-- Create a physical database with a separate database and schema and give it an appropriate domain-related name. 

CREATE DATABASE museum;

CREATE SCHEMA museumschema;


CREATE TABLE IF NOT EXISTS museumschema.exhibition (
    ExhibitionID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Description TEXT
);

CREATE TABLE IF NOT EXISTS museumschema.Employee (
    EmployeeID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Position VARCHAR(50) NOT null
);

CREATE TABLE IF NOT EXISTS museumschema.Visitor (
    VisitorID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100),
    Phone VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS museumschema.Inventory (
    InventoryID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StorageLocation VARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    CurrentItemCount INT NOT NULL
);


CREATE TABLE IF NOT EXISTS museumschema.CollectionItem (
    ItemID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    DateAcquired DATE NOT NULL,
    OriginCountry VARCHAR(50),
    InventoryID INT NOT NULL,
    CONSTRAINT fk_inventory_id FOREIGN KEY (InventoryID) REFERENCES museumschema.Inventory (InventoryID)
);


CREATE TABLE IF NOT EXISTS museumschema.ExhibitionEmployee (
    ExhibitionID INT NOT NULL,
    EmployeeID INT NOT NULL,
    PRIMARY KEY (ExhibitionID, EmployeeID),  --composite primary key
    CONSTRAINT fk_exhibition_id FOREIGN KEY (ExhibitionID) REFERENCES museumschema.Exhibition (ExhibitionID),
    CONSTRAINT fk_employee_id FOREIGN KEY (EmployeeID) REFERENCES museumschema.Employee (EmployeeID)
  );


CREATE TABLE IF NOT EXISTS museumschema.ExhibitionItem (
    ExhibitionID INT NOT NULL,
    ItemID INT NOT NULL,
    PRIMARY KEY (ExhibitionID, ItemID),  --composite primary key
    CONSTRAINT fk_exhibition_id FOREIGN KEY (ExhibitionID) REFERENCES museumschema.Exhibition (ExhibitionID),
    CONSTRAINT fk_item_id FOREIGN KEY (ItemID) REFERENCES museumschema.CollectionItem (ItemID)
);


CREATE TABLE IF NOT EXISTS museumschema.Transaction (
    TransactionID INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Amount Numeric(10,2) NOT NULL,
    TransactionDate DATE NOT NULL,
    VisitorID int NOT NULL,
    ExhibitionID int NOT NULL,
    CONSTRAINT fk_exhibition_id FOREIGN KEY (ExhibitionID) REFERENCES museumschema.Exhibition (ExhibitionID),
    CONSTRAINT fk_visitor_id FOREIGN KEY (VisitorID) REFERENCES museumschema.Visitor (VisitorID)
);


-- Use ALTER TABLE to add at least 5 check constraints across the tables to restrict certain values

-- Ensure that the StartDate of an exhibition is after July 1, 2024
ALTER TABLE museumschema.Exhibition
ADD CONSTRAINT chk_exhibition_start_date CHECK (StartDate > '2024-07-01');

-- Ensure that the Capacity of an Inventory cannot be negative
ALTER TABLE museumschema.Inventory
ADD CONSTRAINT chk_inventory_capacity_positive CHECK (Capacity >= 0);

-- Ensure that the CurrentItemCount of an Inventory cannot exceed its Capacity
ALTER TABLE museumschema.Inventory
ADD CONSTRAINT chk_inventory_item_count CHECK (CurrentItemCount >= 0 AND CurrentItemCount <= Capacity);

-- Ensure that CollectionItem is a valid item that can be present in the museum
ALTER TABLE museumschema.CollectionItem
ADD CONSTRAINT chk_item_type CHECK (Type IN (
    'Painting',
    'Sculpture',
    'Artifact',
    'Manuscript',
    'Photograph',
    'Textile',
    'Jewelry',
    'Ceramic',
    'Furniture',
    'Natural Specimen',
    'Weapon',
    'Coin',
    'Document',
    'Map',
    'Print',
    'Tool',
    'Book'
));

-- Ensure that DateAcquired in CollectionItem is not a future date
ALTER TABLE museumschema.CollectionItem
ADD CONSTRAINT chk_item_date_acquired CHECK (DateAcquired <= CURRENT_DATE);

-- Add UNIQUE constraint to Employee.Email
ALTER TABLE museumschema.Employee
ADD CONSTRAINT uq_employee_email UNIQUE (Email);

-- Add UNIQUE constraint to Visitor.Email
ALTER TABLE museumschema.Visitor
ADD CONSTRAINT uq_visitor_email UNIQUE (Email);


-- Populate the tables with the sample data generated

-- Insert sample data into Inventory table
WITH new_inventory AS 
(
    SELECT 
        'Room A1' AS StorageLocation
        , 100 AS Capacity
        , 50 AS CurrentItemCount
    UNION ALL
    SELECT 
        'Room B2' AS StorageLocation
        , 200 AS Capacity
        , 150 AS CurrentItemCount
    UNION ALL
    SELECT 
        'Room C3' AS StorageLocation
    	, 300 AS Capacity
    	, 250 AS CurrentItemCount
    UNION ALL
    SELECT 
        'Room D4' AS StorageLocation 
    	, 150 AS Capacity
    	, 100 AS CurrentItemCount
    UNION ALL
    SELECT 
        'Room E5' AS StorageLocation 
    	, 120 AS Capacity
    	, 80 AS CurrentItemCount
    UNION ALL
    SELECT 
        'Room F6' AS StorageLocation 
    	, 250 AS Capacity
    	, 200 AS CurrentItemCount
)
INSERT INTO museumschema.Inventory (StorageLocation, Capacity, CurrentItemCount)
SELECT ni.StorageLocation, ni.Capacity, ni.CurrentItemCount
FROM new_inventory ni
WHERE NOT EXISTS (
    SELECT 1
    FROM museumschema.Inventory i
    WHERE UPPER(i.StorageLocation) = UPPER(ni.StorageLocation)
)
RETURNING *;


-- Insert sample data into CollectionItem table
WITH new_collection_items AS 
(
    SELECT 
        'Mona Lisa' AS Name, 'Painting' AS Type, DATE '2024-09-01' AS DateAcquired, 'France' AS OriginCountry, 
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room A1') LIMIT 1) AS InventoryID
    UNION ALL
    SELECT 
        'The Thinker', 'Sculpture', DATE '2024-10-05', 'USA',
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room B2') LIMIT 1)
    UNION ALL
    SELECT 
        'Ancient Vase', 'Artifact', DATE '2024-11-15', 'Greece', 
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room C3') LIMIT 1)
    UNION ALL
    SELECT 
        'Old Manuscript', 'Manuscript', DATE '2024-08-20', 'UK',
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room D4') LIMIT 1)
    UNION ALL
    SELECT 
        'Historical Map', 'Map', DATE '2024-09-10', 'Italy',
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room E5') LIMIT 1)
    UNION ALL
    SELECT 
        'Rare Coin', 'Coin', DATE '2024-07-25', 'India', 
        (SELECT InventoryID FROM museumschema.Inventory WHERE UPPER(StorageLocation) = UPPER('Room F6') LIMIT 1)
)
INSERT INTO museumschema.CollectionItem (Name, Type, DateAcquired, OriginCountry, InventoryID)
SELECT nci.Name, nci.Type, nci.DateAcquired, nci.OriginCountry, nci.InventoryID
FROM new_collection_items nci
WHERE NOT EXISTS (
    SELECT 1
    FROM museumschema.CollectionItem ci
    WHERE UPPER(ci.Name) = UPPER(nci.Name)
)
RETURNING *;

-- Insert sample data into Employee table
WITH new_employees AS 
(
    SELECT 
        'John' AS FirstName, 'Doe' AS LastName, 'john.doe@example.com' AS Email, '+1234567890' AS Phone, 'Curator' AS Position
    UNION ALL
    SELECT 
        'Jane', 'Smith', 'jane.smith@example.com', '+1987654321', 'Guide'
    UNION ALL
    SELECT 
        'Michael', 'Johnson', 'm.johnson@example.com', '+1122334455', 'Administrator'
    UNION ALL
    SELECT 
        'Emily', 'Brown', 'e.brown@example.com', '+1222333444', 'Cleaner'
    UNION ALL
    SELECT 
        'Chris', 'Wilson', 'c.wilson@example.com', '+1777888999', 'Security'
    UNION ALL
    SELECT 
        'Sarah', 'Taylor', 's.taylor@example.com', '+1444555666', 'Guide'
)
INSERT INTO museumschema.Employee (FirstName, LastName, Email, Phone, Position)
SELECT ne.FirstName, ne.LastName, ne.Email, ne.Phone, ne.Position
FROM new_employees ne
WHERE NOT EXISTS (
    SELECT 1
    FROM museumschema.Employee e
    WHERE UPPER(e.Email) = UPPER(ne.Email)
)
RETURNING *;

-- Insert sample data into Visitor table
WITH new_visitors AS 
(
    SELECT 
        'Alice' AS FirstName, 'Green' AS LastName, 'alice.green@example.com' AS Email, '+1999888777' AS Phone
    UNION ALL
    SELECT 
        'Charlie', 'Black', 'charlie.black@example.com', '+1777666555'
    UNION ALL
    SELECT 
        'Bob', 'White', 'bob.white@example.com', '+1888777666'
    UNION ALL
    SELECT 
        'Eve', 'Blue', 'eve.blue@example.com', '+1444333222'
    UNION ALL
    SELECT 
        'Grace', 'Purple', 'grace.purple@example.com', '+1666888777'
    UNION ALL
    SELECT 
        'Hannah', 'Brown', 'hannah.brown@example.com', '+1555332233'
)
INSERT INTO museumschema.Visitor (FirstName, LastName, Email, Phone)
SELECT nv.FirstName, nv.LastName, nv.Email, nv.Phone
FROM new_visitors nv
ON CONFLICT (Email) DO NOTHING;
-- Insert sample data into Exhibition table
WITH new_exhibitions AS 
(
    SELECT 
        'Modern Art Showcase' AS Name, DATE '2024-09-01' AS StartDate, DATE '2024-09-30' AS EndDate, 'Exhibition featuring modern art pieces.' AS Description
    UNION ALL
    SELECT 
        'Ancient Sculptures', DATE '2024-10-05', DATE '2024-10-25', 'Collection of ancient sculptures from around the world.'
    UNION ALL
    SELECT 
        'Historical Manuscripts', DATE '2024-11-01', DATE '2024-11-15', 'Rare manuscripts showcasing history.'
    UNION ALL
    SELECT 
        'Coin Collectors Delight', DATE '2024-08-15', DATE '2024-09-10', 'Rare coins from ancient civilizations.'
    UNION ALL
    SELECT 
        'The World in Maps', DATE '2024-09-20', DATE '2024-10-10', 'Maps showcasing the evolution of cartography.'
    UNION ALL
    SELECT 
        'Famous Paintings', DATE '2024-10-20', DATE '2024-11-10', 'Paintings by renowned artists.'
)
INSERT INTO museumschema.Exhibition (Name, StartDate, EndDate, Description)
SELECT ne.Name, ne.StartDate, ne.EndDate, ne.Description
FROM new_exhibitions ne
WHERE NOT EXISTS (
    SELECT 1
    FROM museumschema.Exhibition e
    WHERE UPPER(e.Name) = UPPER(ne.Name)
)
RETURNING *;



-- Insert sample data into ExhibitionEmployee table
WITH new_exhibition_employee AS  
(
    SELECT 
        (SELECT employeeid FROM museumschema.employee WHERE UPPER(firstName) = 'JOHN' AND UPPER(lastName) = 'DOE') AS EmployeeID,
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'MODERN ART SHOWCASE') AS ExhibitionID
    UNION ALL
    SELECT 
        (SELECT employeeid FROM museumschema.employee WHERE UPPER(firstName) = 'CHRIS' AND UPPER(lastName) = 'WILSON') AS EmployeeID,
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'FAMOUS PAINTINGS') AS ExhibitionID
)
INSERT INTO museumschema.exhibitionemployee (EmployeeID, ExhibitionID)
SELECT nee.EmployeeID, nee.ExhibitionID
FROM new_exhibition_employee nee
ON CONFLICT DO NOTHING
RETURNING *;

-- Insert sample data into ExhibitionItem table
WITH new_exhibition_item AS  
(
    SELECT 
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'MODERN ART SHOWCASE') AS ExhibitionID,
        (SELECT itemid FROM museumschema.collectionitem WHERE UPPER(name) = 'MONA LISA') AS ItemID
    UNION ALL
    SELECT 
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'FAMOUS PAINTINGS') AS ExhibitionID,
        (SELECT itemid FROM museumschema.collectionitem WHERE UPPER(name) = 'RARE COIN') AS ItemID
)
INSERT INTO museumschema.exhibitionitem (ExhibitionID, ItemID)
SELECT nei.ExhibitionID, nei.ItemID
FROM new_exhibition_item nei
WHERE NOT EXISTS (
    SELECT 1 
    FROM museumschema.exhibitionitem ei 
    WHERE ei.ExhibitionID = nei.ExhibitionID AND ei.ItemID = nei.ItemID
)
ON CONFLICT DO NOTHING
RETURNING *;

-- Insert sample data into Transactions Table
WITH new_transactions AS 
(
    SELECT 
        19.99 AS Amount, 
        DATE '2024-01-10' AS TransactionDate,
        (SELECT visitorid FROM museumschema.visitor WHERE UPPER(firstname) = 'ALICE' AND UPPER(lastname) = 'GREEN') AS VisitorID,
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'MODERN ART SHOWCASE') AS ExhibitionID
    UNION ALL
    SELECT 
        25.00, 
        DATE '2024-02-05',
        (SELECT visitorid FROM museumschema.visitor WHERE UPPER(firstname) = 'GRACE' AND UPPER(lastname) = 'PURPLE'),
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'FAMOUS PAINTINGS')
    UNION ALL
    SELECT 
        25.00, 
        DATE '2024-04-05',
        (SELECT visitorid FROM museumschema.visitor WHERE UPPER(firstname) = 'BOB' AND UPPER(lastname) = 'WHITE'),
        (SELECT exhibitionid FROM museumschema.exhibition WHERE UPPER(name) = 'FAMOUS PAINTINGS')
)
INSERT INTO museumschema.Transaction (Amount, TransactionDate, VisitorID, ExhibitionID)
SELECT nt.Amount, nt.TransactionDate, nt.VisitorID, nt.ExhibitionID
FROM new_transactions nt
WHERE NOT EXISTS (
    SELECT 1 
    FROM museumschema.Transaction t 
    WHERE t.VisitorID = nt.VisitorID AND t.ExhibitionID = nt.ExhibitionID AND t.TransactionDate = nt.TransactionDate
)
ON CONFLICT DO NOTHING
RETURNING *;



-- Create a function that updates data in one of your tables

-- Create the function to update employee details
CREATE OR REPLACE FUNCTION museumschema.update_employee(
    p_employee_id INT,
    p_column_name VARCHAR(50),
    p_new_value VARCHAR
)
RETURNS VOID AS
$$
BEGIN
    IF p_column_name = 'FirstName' THEN
        UPDATE museumschema.Employee
        SET FirstName = p_new_value
        WHERE EmployeeID = p_employee_id;
    ELSIF p_column_name = 'LastName' THEN
        UPDATE museumschema.Employee
        SET LastName = p_new_value
        WHERE EmployeeID = p_employee_id;
    ELSIF p_column_name = 'Email' THEN
        UPDATE museumschema.Employee
        SET Email = p_new_value
        WHERE EmployeeID = p_employee_id;
    ELSIF p_column_name = 'Phone' THEN
        UPDATE museumschema.Employee
        SET Phone = p_new_value
        WHERE EmployeeID = p_employee_id;
    ELSIF p_column_name = 'Position' THEN
        UPDATE museumschema.Employee
        SET Position = p_new_value
        WHERE EmployeeID = p_employee_id;
    ELSE
        RAISE EXCEPTION 'Invalid column name: %', p_column_name;
    END IF;
END;
$$
LANGUAGE plpgsql;



-- Create function to insert a new transaction
CREATE OR REPLACE FUNCTION museumschema.add_transaction(
    p_amount NUMERIC(10,2),
    p_transaction_date DATE,
    p_visitor_email VARCHAR(100),
    p_exhibition_name VARCHAR(100)
)
RETURNS VOID AS
$$
DECLARE
    v_visitor_id INT;
    v_exhibition_id INT;
BEGIN
    SELECT VisitorID INTO v_visitor_id
    FROM museumschema.Visitor
    WHERE Email = p_visitor_email;

    IF v_visitor_id IS NULL THEN
        RAISE EXCEPTION 'Visitor with email % does not exist.', p_visitor_email;
    END IF;

    SELECT ExhibitionID INTO v_exhibition_id
    FROM museumschema.Exhibition
    WHERE Name = p_exhibition_name;

    IF v_exhibition_id IS NULL THEN
        RAISE EXCEPTION 'Exhibition with name % does not exist.', p_exhibition_name;
    END IF;

    INSERT INTO museumschema.Transaction (Amount, TransactionDate, VisitorID, ExhibitionID)
    VALUES (p_amount, p_transaction_date, v_visitor_id, v_exhibition_id);

    RAISE NOTICE 'Transaction successfully added for visitor % at exhibition %.', p_visitor_email, p_exhibition_name;
END;
$$
LANGUAGE plpgsql;

-- Create a view that presents analytics for the most recently added quarter in your database.
-- Ensure that the result excludes irrelevant fields such as surrogate keys and duplicate entries.
CREATE VIEW museumschema.analytics_recent_quarter AS
WITH recent_quarter AS (
    SELECT
        DATE_TRUNC('quarter', MAX(TransactionDate)) AS quarter_start,
        DATE_TRUNC('quarter', MAX(TransactionDate)) + INTERVAL '3 months' - INTERVAL '1 day' AS quarter_end
    FROM museumschema.Transaction
)
SELECT
    rq.quarter_start,
    rq.quarter_end,
    COUNT(t.TransactionID) AS total_transactions,
    SUM(t.Amount) AS total_amount,
    COUNT(DISTINCT t.VisitorID) AS unique_visitors
FROM
    museumschema.Transaction t
JOIN
    recent_quarter rq ON t.TransactionDate BETWEEN rq.quarter_start AND rq.quarter_end
GROUP BY
    rq.quarter_start, rq.quarter_end;



CREATE ROLE manager_read_only;

ALTER ROLE manager_read_only WITH LOGIN;

GRANT SELECT ON ALL TABLES IN SCHEMA museumschema TO manager_read_only;

ALTER DEFAULT PRIVILEGES IN SCHEMA museumschema GRANT SELECT ON TABLES TO manager_read_only;

REVOKE ALL ON DATABASE museum FROM manager_read_only;
REVOKE ALL ON SCHEMA museumschema FROM manager_read_only;

REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA museumschema FROM manager_read_only;





