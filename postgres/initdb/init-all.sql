-- Create tables.
CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,   -- Generated using a UUID
    name VARCHAR(255),              -- Generated using full name string
    birthday DATE,                  -- Generated as a date (string format converted to date)
    direct_subscription BOOLEAN,    -- Boolean value
    membership_level VARCHAR(50),   -- One of 'free', 'pro', or 'elite'
    shipping_address TEXT,          -- Full address as string
    activation_date TIMESTAMP       -- Generated with formatDateTime
);

CREATE TABLE orders (
    order_id UUID PRIMARY KEY,               -- Generated using a UUID
    customer_id UUID REFERENCES customers(customer_id), -- Lookup to customers table
    order_number SERIAL,                     -- Sequential integer
    product VARCHAR(255),                    -- Generated as a product name string
    backordered BOOLEAN,                     -- Weighted boolean: mostly false
    cost FLOAT,                              -- (better to use DECIMAL for currency, using float for simplicity)
    description TEXT,                        -- Generated as a paragraph
    create_ts TIMESTAMP DEFAULT NOW(),       -- Timestamp for creation, defaulting to current time
    credit_card_number VARCHAR(16),          -- String for credit card number
    discount_percent INT                     -- Integer for discount percentage
);
