# Wavze-DB-Schema

A comprehensive PostgreSQL database schema designed for a flexible, industry-agnostic foundation. This schema is complete with automatic history tracking, duplicate detection, and data integrity constraints.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Database Schema](#database-schema)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Table Structure](#table-structure)
- [Triggers and Functions](#triggers-and-functions)
- [Data Files](#data-files)
- [Contributing](#contributing)
- [License](#license)

## Overview

This project contains a complete PostgreSQL database schema for managing customer transactions of interested product leads. The schema is designed with industry-agnostic core tables that can be adapted for other industries, while the `transaction_detail` table contains banking-specific fields.

**Key Design Principles:**
- Industry-agnostic core tables (customer, product, property, transaction)
- Banking-specific transaction details
- Automatic audit trail through history tables
- UUID-based primary keys for distributed systems
- Comprehensive trigger-based automation

## Features

- **Automatic History Tracking**: All changes to customer, product, property, and transaction records are automatically logged in corresponding history tables
- **Duplicate Detection**: Built-in triggers prevent duplicate customer entries and flag duplicate transactions with more than one active product_id/customer_id combo
- **Automatic Timestamps**: Created and modified timestamps are automatically managed
- **Data Integrity**: Foreign key constraints ensure referential integrity across all tables
- **Product Lookup**: Automatic product ID resolution from product category and name
- **Transaction Status Management**: Automatic status updates based on transaction milestones
- **Property Relationship Management**: Automatic primary residence tracking and customer address synchronization

## Database Schema

### Core Tables

- **wavze_user**: System users and administrators
- **customer**: Customer information and demographics
- **product**: Product catalog with categories
- **property**: Property/real estate information
- **transaction**: Main transaction records
- **transaction_detail**: Banking-specific transaction details (fields will change for each industry template)
- **property_rltn**: Customer-property relationships

### History Tables

- **customer_hist**: Complete audit trail of customer changes
- **product_hist**: Product modification history
- **transaction_hist**: Transaction change history
- **property_hist**: Property modification history

### Derived Metric Table
- **transaction_milestone_kpi**: Banking-specific milestone KPIs (fields will change for each industry template)

### Reporting Materialized View
- **kpi_ytd_by_user**: Banking-specific aggregated milestone KPIs (fields will change for each industry template)

## Prerequisites

- PostgreSQL 12 or higher
- pgAdmin 4 (recommended for GUI management) or psql command-line tool
- Database user with CREATE TABLE, CREATE FUNCTION, and CREATE TRIGGER privileges
- UUID extension enabled (usually available by default)

## Installation

### Step 1: Create Database and Schema

```sql
-- Connect to your PostgreSQL server
-- Create the database (if it doesn't exist)
CREATE DATABASE wavzedemo;

-- Connect to the database
\c wavzedemo

-- Create the schema
CREATE SCHEMA wavzedemo;

-- Ensure UUID extension is available
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

### Step 2: Set Up Database User

```sql
-- Create a user (adjust username as needed)
CREATE USER "your-email@example.com" WITH PASSWORD 'your-password';

-- Grant necessary privileges
GRANT ALL PRIVILEGES ON SCHEMA wavzedemo TO "your-email@example.com";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA wavzedemo TO "your-email@example.com";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA wavzedemo TO "your-email@example.com";
```

### Step 3: Execute SQL Files

Execute the SQL files in the following order to ensure dependencies are met:

1. **wavze_user.sql** - User table (no dependencies)
2. **property.sql** - Property table (depends on wavze_user)
3. **customer.sql** - Customer table (depends on wavze_user, property if a Primary Residence is available)
4. **product.sql** - Product table (depends on wavze_user)
5. **transaction.sql** - Transaction table (depends on customer, product, property, wavze_user)
6. **transaction_detail.sql** - Transaction details (depends on transaction, customer, wavze_user)
7. **property_rltn.sql** - Property relationships (depends on property, customer)
8. **customer_hist.sql** - Customer history (depends on customer, wavze_user)
9. **product_hist.sql** - Product history (depends on product, wavze_user)
10. **transaction_hist.sql** - Transaction history (depends on transaction, wavze_user)
11. **property_hist.sql** - Property history (depends on property, wavze_user)
12. **transaction_milestone_kpi.sql** - Milestone KPI flags (depends on transaction, customer)
13. **kpi_ytd_by_user.sql** - Aggregated KPI view 

### Using pgAdmin 4

1. Open pgAdmin 4
2. Connect to your PostgreSQL server
3. Right-click on your database → Query Tool
4. Open each SQL file in order and execute them

### Using psql Command Line

```bash
# Navigate to the project directory
cd /path/to/Wavze-DB-Schema

# Execute files in order
psql -U your-username -d wavzedemo -f wavze_user.sql
psql -U your-username -d wavzedemo -f property.sql
psql -U your-username -d wavzedemo -f customer.sql
psql -U your-username -d wavzedemo -f product.sql
psql -U your-username -d wavzedemo -f transaction.sql
psql -U your-username -d wavzedemo -f transaction_detail.sql
psql -U your-username -d wavzedemo -f property_rltn.sql
psql -U your-username -d wavzedemo -f customer_hist.sql
psql -U your-username -d wavzedemo -f product_hist.sql
psql -U your-username -d wavzedemo -f transaction_hist.sql
psql -U your-username -d wavzedemo -f property_hist.sql
psql -U your-username -d wavzedemo -f transaction_milestone_kpi.sql
psql -U your-username -d wavzedemo -f kpi_ytd_by_user.sql
```

## Usage

### Basic Operations

#### Creating a Customer

```sql
INSERT INTO wavzedemo.customer (
    first_name,
    last_name,
    email,
    phn1_type,
    phn1_nbr,
    created_by
) VALUES (
    'John',
    'Doe',
    'john.doe@example.com',
    'Mobile',
    1234567890,
    'your-user-uuid-here'
);
```

#### Creating a Product

```sql
INSERT INTO wavzedemo.product (
    product_category,
    product_name,
    product_active,
    created_by
) VALUES (
    'Mortgage Purchase',
    '30-Year Fixed',
    true,
    'your-user-uuid-here'
);
```

#### Creating a Transaction

```sql
INSERT INTO wavzedemo.transaction (
    customer_id,
    product_category,
    product_name,
    source,
    milestone,
    created_by
) VALUES (
    'customer-uuid-here',
    'Mortgage Purchase',
    '30-Year Fixed',
    'Online',
    'Application',
    'your-user-uuid-here'
);
```

**Note**: The `product_id` will be automatically resolved from `product_category` and `product_name` by the trigger.

#### Creating a Property

```sql
INSERT INTO wavzedemo.property (
    street_addr1,
    city,
    state,
    zip_cde,
    country,
    prop_type,
    created_by
) VALUES (
    '123 Main St',
    'Anytown',
    'CA',
    '12345',
    'United States',
    'Single Family',
    'your-user-uuid-here'
);
```

#### Linking Property to Customer

```sql
INSERT INTO wavzedemo.property_rltn (
    property_id,
    customer_id,
    occupancy
) VALUES (
    'property-uuid-here',
    'customer-uuid-here',
    'Primary Residence'
);
```

**Note**: Setting `occupancy` to 'Primary Residence' will automatically:
- Set `prim_residence = TRUE`
- Update the customer's `property_id` and address fields

### Querying History

#### View Customer Change History

```sql
SELECT 
    ch.customer_hist_id,
    ch.operation,
    ch.field_name,
    ch.old_value,
    ch.new_value,
    ch.modified_ts,
    c.first_name || ' ' || c.last_name AS customer_name
FROM wavzedemo.customer_hist ch
JOIN wavzedemo.customer c ON c.customer_id = ch.customer_id
WHERE ch.customer_id = 'customer-uuid-here'
ORDER BY ch.modified_ts DESC;
```

#### View Transaction History

```sql
SELECT 
    th.transaction_id,
    th.operation,
    th.field_name,
    th.old_value,
    th.new_value,
    th.modified_ts
FROM wavzedemo.transaction_hist th
WHERE th.transaction_id = 'transaction-uuid-here'
ORDER BY th.modified_ts DESC;
```

### Checking for Duplicates

The system automatically prevents duplicate customers based on:
- Matching first name and last name
- Matching email address
- Matching phone numbers

Duplicate transactions are automatically flagged when multiple active transactions exist for the same customer and product.

## Table Structure

### wavze_user
Stores system users and administrators.

**Key Fields:**
- `user_id` (UUID, Primary Key)
- `username`, `email`, `first_name`, `last_name`
- `nmls_id` (for mortgage professionals)
- Contact and address information

### customer
Stores customer information and demographics.

**Key Fields:**
- `customer_id` (UUID, Primary Key)
- `property_id` (FK to property) - Primary residence
- `first_name`, `last_name`, `email`
- `phn1_nbr`, `phn2_nbr` - Phone numbers
- `birth_date`, `marital_status`
- `annual_income`, `est_credit_range`
- Address fields
- `created_ts`, `modified_ts` (auto-managed)

### product
Stores product catalog information.

**Key Fields:**
- `product_id` (UUID, Primary Key)
- `product_category` (e.g., "Mortgage Purchase", "Credit Card")
- `product_name` (e.g., "30-Year Fixed", "Premium Rewards")
- `product_active` (boolean) - Product availability status

### property
Stores property/real estate information.

**Key Fields:**
- `property_id` (UUID, Primary Key)
- Address fields (`street_addr1`, `city`, `state`, `zip_cde`, etc.)
- `prop_type` - Property type
- `purchase_date`, `est_prop_value`
- `appraisal_src` - Appraisal source

### transaction
Main transaction records linking customers to products.

**Key Fields:**
- `transaction_id` (UUID, Primary Key)
- `customer_id` (FK, Required)
- `product_id` (FK, Required) - Auto-resolved from category/name
- `property_id` (FK, Optional)
- `user_id`, `bob_id`, `coi_id` (FKs to wavze_user)
- `product_category`, `product_name` - Used for product lookup
- `source` - Transaction source
- `milestone` - Transaction status (e.g., "Application", "Closed", "Funded")
- `active` (boolean) - Auto-set to FALSE when milestone contains "CLOSED" or "FUNDED"
- `duplicate` (boolean) - Auto-flagged for duplicate transactions

### transaction_detail
Banking-specific transaction details (industry-specific).

**Key Fields:**
- `transaction_id` (UUID, Primary Key, FK to transaction)
- `purchase_price`, `down_payment`, `loan_amount`
- `loan_term_type`, `loan_term`
- `interest_rate`, `apr`
- `lien_position`, `rate_type`
- `pmi` (Private Mortgage Insurance)
- `cash_out`, `draw_amount`
- `credit_limit`, `cash_advance`
- `deposit_amount`, `funding_method`
- `ownership_type`
- Co-applicant fields (`co_appl1`, `co_appl2`)

### property_rltn
Manages customer-property relationships.

**Key Fields:**
- `property_rltn_id` (UUID, Primary Key)
- `property_id` (FK, Required)
- `customer_id` (FK)
- `prim_residence` (boolean) - Auto-set from occupancy
- `occupancy` - Relationship type (e.g., "Primary Residence")

## Triggers and Functions

### Automatic Timestamp Management

**Function**: `wavzedemo.set_created_ts()`
- Automatically sets `created_ts` to current timestamp if NULL on INSERT
- Applied to: customer, product, property, transaction, transaction_detail, property_rltn

### History Tracking

**Functions**: 
- `wavzedemo.track_customer_field_changes()`
- `wavzedemo.track_product_field_changes()`
- `wavzedemo.track_transaction1_field_changes()`
- `wavzedemo.track_transaction2_field_changes()`
- `wavzedemo.track_property_field_changes()`

These functions automatically log all field changes to respective history tables, storing:
- Operation type (INSERT, UPDATE, DELETE)
- Field name and data type
- Old and new values (as JSONB)
- Timestamp of change

### Duplicate Detection

**Function**: `wavzedemo.customer_uuid_dup_check()`
- Prevents duplicate customers based on name, email, or phone number
- Raises exception if duplicate found

**Function**: `wavzedemo.transaction_dup_check()`
- Flags duplicate transactions (same customer + product + active status)
- Sets `duplicate = TRUE` on all related transactions

### Product Lookup

**Function**: `wavzedemo.product_id_lookup()`
- Automatically resolves `product_id` from `product_category` and `product_name`
- Raises exception if product not found

### Transaction Status Management

**Function**: `wavzedemo.transaction_active_check()`
- Automatically sets `active = FALSE` when milestone contains "CLOSED" or "FUNDED"

### Property Relationship Management

**Function**: `wavzedemo.set_prim_residence_from_occupancy()`
- Sets `prim_residence = TRUE` when `occupancy = 'Primary Residence'`

**Function**: `wavzedemo.update_customer_prim_residence()`
- Automatically updates customer's `property_id` and address when primary residence changes
- Handles deletion of primary residence relationships

### Transaction Detail Auto-Creation

**Functions**: 
- `wavzedemo.transaction_detail_uuid()`
- `wavzedemo.transaction_milestone_kpi_uuid()`
- Automatically creates a corresponding `transaction_detail` and `transaction_milestone_kpi` record when a transaction is created

### Last Modified Updates

**Function**: `wavzedemo.update_customer_last_modified()`
- Updates customer's `modified_ts` and `modified_by` from latest history record

## Data Files

### dynamic_detail_fields.csv
Defines which fields are active for each product category in the transaction_detail table. Used for dynamic form generation.

**Columns:**
- `product category` - Product category name
- `field name` - Field name in transaction_detail table
- `field_sequence` - Display order
- `field_active` - Whether field is active (TRUE/FALSE)

### product_setup_options.csv
(If present) Contains product setup configuration options. This is a banking industry example and supports the client's initial setup of their Wavze application.

## KPI Aggregate Views

The schema includes dynamic KPI aggregate views for comprehensive transaction analytics:

### kpi_aggregate_view

A detailed view that provides comprehensive KPI aggregations across transactions, grouped by:
- Product category and name
- Milestone (transaction status)
- Source
- Time dimensions (date, month, quarter, year)

**Key Metrics Included:**
- Transaction counts (total, active, closed, duplicates, time-sensitive)
- Customer metrics (unique customers, active customers)
- Financial aggregations (loan amounts, purchase prices, deposits, credit limits)
- Interest rate and APR statistics
- Conversion metrics (application → approved → closed → funded rates)
- Distribution statistics (rate types, ownership types, lien positions)

### kpi_summary_view

A high-level summary view that aggregates `kpi_aggregate_view` data for dashboard reporting:
- Aggregated by product category and time periods
- Weighted averages for financial metrics
- Overall conversion rates
- Active vs closed ratios

### Usage Examples

See `kpi_view_usage_examples.sql` for comprehensive query examples including:
- Monthly KPI summaries by product category
- Conversion funnel analysis
- Source performance comparison
- Quarter-over-quarter growth analysis
- Product-specific KPI queries

**Example Query:**
```sql
-- Get monthly summary for all products
SELECT 
    product_category,
    transaction_month,
    total_transactions,
    total_loan_amount,
    overall_approval_rate_pct,
    overall_close_rate_pct
FROM wavzedemo.kpi_summary_view
WHERE transaction_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '12 months')
ORDER BY product_category, transaction_month DESC;
```

### Installation

Execute the KPI view files after creating the base schema:
```bash
psql -U your-username -d wavzedemo -f kpi_aggregate_view.sql
psql -U your-username -d wavzedemo -f kpi_summary_view.sql
```

## Contributing

We welcome contributions to improve this database schema! Please follow these guidelines:

### Contribution Process

1. **Fork the Repository**: Create your own fork of the repository
2. **Create a Feature Branch**: 
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make Your Changes**: 
   - Follow existing code style and naming conventions
   - Ensure all SQL is properly formatted
   - Test your changes in a development database
   - Update documentation as needed
4. **Test Your Changes**:
   - Verify all triggers and functions work correctly
   - Test edge cases and error conditions
   - Ensure foreign key constraints are maintained
5. **Commit Your Changes**:
   ```bash
   git commit -m "Description of your changes"
   ```
6. **Push and Create Pull Request**: 
   - Push to your fork
   - Create a pull request with a clear description of changes

### Code Style Guidelines

- Use consistent indentation (tabs or spaces, match existing code)
- Include comments for complex logic
- Use descriptive variable and function names
- Follow PostgreSQL naming conventions:
  - Table names: lowercase, singular (e.g., `customer`, `transaction`)
  - Column names: lowercase, snake_case (e.g., `customer_id`, `created_ts`)
  - Function names: schema-prefixed, descriptive (e.g., `wavzedemo.set_created_ts()`)

### Testing Guidelines

Before submitting a pull request, please test:
- All INSERT operations work correctly
- All UPDATE operations trigger history logging
- All DELETE operations are properly logged
- Foreign key constraints prevent invalid data
- Triggers execute in correct order
- No SQL syntax errors in pgAdmin or psql

### Reporting Issues

If you find a bug or have a suggestion:
1. Check existing issues to avoid duplicates
2. Create a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs. actual behavior
   - PostgreSQL version
   - Relevant error messages

