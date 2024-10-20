INSERT INTO customers (customer_id, name, birthday, direct_subscription, membership_level, shipping_address, activation_date)
VALUES 
('550e8400-e29b-41d4-a716-446655440000', 'John Doe', '1985-06-15', true, 'pro', '1234 Elm St, Springfield, IL', '2024-10-20 10:45:00'),
('7c62c57b-3d43-470b-b5f3-efa56c8d14ad', 'Jane Smith', '1990-03-22', false, 'elite', '5678 Maple St, Boston, MA', '2024-10-19 14:20:30'),
('e0b70fdc-9cd4-44f8-baca-962f1b58273b', 'Alice Johnson', '1972-12-09', true, 'free', '7890 Oak St, Dallas, TX', '2024-10-18 08:05:45');


INSERT INTO orders (order_id, customer_id, order_number, product, backordered, cost, description, create_ts, credit_card_number, discount_percent)
VALUES 
('c5d90277-bb8d-4a34-90eb-b3c71a885cda', '550e8400-e29b-41d4-a716-446655440000', 1, 'Laptop', false, 120.50, 'High-performance laptop with 16GB RAM and SSD.', '2024-10-20 11:00:00', '4111111111111111', 5),
('b4920b7e-f60b-48b6-834e-2edba9d59c94', '7c62c57b-3d43-470b-b5f3-efa56c8d14ad', 2, 'Wireless Mouse', true, 25.75, 'Ergonomic wireless mouse with adjustable DPI settings.', '2024-10-20 12:15:30', '4222222222222222', 7),
('a8e5f8c2-9184-4c65-bbaa-523ce7deab33', 'e0b70fdc-9cd4-44f8-baca-962f1b58273b', 3, 'Smartphone', false, 299.99, 'Latest smartphone model with OLED display and 5G connectivity.', '2024-10-20 13:30:15', '4333333333333333', 3);
