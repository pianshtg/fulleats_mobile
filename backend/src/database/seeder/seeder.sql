CREATE DATABASE IF NOT EXISTS fulleats;
USE fulleats;

CREATE TABLE user (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(100),
    image_url VARCHAR(255)
);

CREATE TABLE hashed_password (
    user_id CHAR(36) PRIMARY KEY,
    hashed_password VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE hashed_refresh_token (
    user_id CHAR(36) PRIMARY KEY,
    hashed_refresh_token VARCHAR(255) NOT NULL,
    expires_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

CREATE TABLE restaurant (
    user_id CHAR(36) PRIMARY KEY,
    name VARCHAR (100),
    location VARCHAR (100),
    menu JSON,
    image_url VARCHAR (255),
    FOREIGN KEY (user_id) REFERENCES user(id) ON DELETE CASCADE
);

-- Insert admin user
INSERT INTO user (
    id,
    email,
    name,
    image_url
) VALUES (
    UUID(),
    'admin@example.com',
    'admin',
    NULL
);

INSERT INTO hashed_password (
    user_id,
    hashed_password
) VALUES (
    (
        SELECT id
        FROM user
        WHERE email = 'admin@example.com'
    ),
    'admin'
);

-- Restaurant 1: Pizza Pengkolan
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'pizza.pengkolan@example.com', 'Pizza Pengkolan Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'pizza.pengkolan@example.com'),
    'Pizza Pengkolan',
    'Jl. Hiha',
    JSON_OBJECT(
        'Margherita Pizza', 129900,
        'Pepperoni Pizza', 149900,
        'Caesar Salad', 89900,
        'Garlic Bread', 59900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 2: Burger Bangor
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'burger.bangor@example.com', 'Burger Bangor Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'burger.bangor@example.com'),
    'Burger Bangor',
    'Jl. Haha',
    JSON_OBJECT(
        'Classic Burger', 109900,
        'Cheeseburger', 119900,
        'Fries', 49900,
        'Milkshake', 69900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 3: Sushi Susha
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'sushi.susha@example.com', 'Sushi Susha Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'sushi.susha@example.com'),
    'Sushi Susha',
    'Jl. Hihi',
    JSON_OBJECT(
        'California Roll', 89900,
        'Salmon Nigiri', 129900,
        'Miso Soup', 49900,
        'Green Tea', 29900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 4: Nasi Padang Minang
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'padang.minang@example.com', 'Nasi Padang Minang Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'padang.minang@example.com'),
    'Nasi Padang Minang',
    'Jl. Sudirman No. 45',
    JSON_OBJECT(
        'Nasi Rendang', 89900,
        'Ayam Pop', 79900,
        'Gulai Kambing', 109900,
        'Sayur Nangka', 39900,
        'Es Teh Manis', 19900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 5: Taco Fiesta
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'taco.fiesta@example.com', 'Taco Fiesta Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'taco.fiesta@example.com'),
    'Taco Fiesta',
    'Jl. Kemang Raya No. 88',
    JSON_OBJECT(
        'Beef Tacos', 99900,
        'Chicken Quesadilla', 89900,
        'Nachos with Cheese', 69900,
        'Guacamole', 59900,
        'Margarita Mocktail', 49900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 6: Ramen Ichiban
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'ramen.ichiban@example.com', 'Ramen Ichiban Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'ramen.ichiban@example.com'),
    'Ramen Ichiban',
    'Jl. Senopati No. 12',
    JSON_OBJECT(
        'Tonkotsu Ramen', 139900,
        'Miso Ramen', 129900,
        'Gyoza', 79900,
        'Chicken Karaage', 89900,
        'Matcha Latte', 39900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 7: Thai Garden
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'thai.garden@example.com', 'Thai Garden Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'thai.garden@example.com'),
    'Thai Garden',
    'Jl. Panglima Polim No. 67',
    JSON_OBJECT(
        'Pad Thai', 99900,
        'Green Curry', 119900,
        'Tom Yum Soup', 89900,
        'Mango Sticky Rice', 69900,
        'Thai Iced Tea', 29900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 8: Mediterranean Delight
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'mediterranean.delight@example.com', 'Mediterranean Delight Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'mediterranean.delight@example.com'),
    'Mediterranean Delight',
    'Jl. Cipete Raya No. 34',
    JSON_OBJECT(
        'Greek Gyros', 109900,
        'Hummus Platter', 79900,
        'Falafel Bowl', 99900,
        'Baklava', 59900,
        'Mint Lemonade', 39900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 9: Indian Spice House
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'indian.spice@example.com', 'Indian Spice House Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'indian.spice@example.com'),
    'Indian Spice House',
    'Jl. Blok M No. 78',
    JSON_OBJECT(
        'Butter Chicken', 129900,
        'Biryani Rice', 109900,
        'Naan Bread', 49900,
        'Samosa', 59900,
        'Mango Lassi', 39900
    ),
    'https://via.placeholder.com/150'
);

-- Restaurant 10: Korean BBQ Seoul
INSERT INTO user (id, email, name, image_url) 
VALUES (UUID(), 'korean.seoul@example.com', 'Korean BBQ Seoul Owner', 'https://via.placeholder.com/150');

INSERT INTO restaurant (user_id, name, location, menu, image_url)
VALUES (
    (SELECT id FROM user WHERE email = 'korean.seoul@example.com'),
    'Korean BBQ Seoul',
    'Jl. Gandaria No. 56',
    JSON_OBJECT(
        'Bulgogi BBQ', 149900,
        'Kimchi Fried Rice', 99900,
        'Korean Fried Chicken', 119900,
        'Bibimbap', 109900,
        'Korean Banana Milk', 29900
    ),
    'https://via.placeholder.com/150'
);