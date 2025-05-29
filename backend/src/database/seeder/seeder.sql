CREATE DATABASE IF NOT EXISTS fulleats;
USE fulleats;
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    nama VARCHAR(100),
    link_gambar VARCHAR(255)
);
CREATE TABLE users_hashed_password (
    user_id CHAR(36) PRIMARY KEY,
    hashed_password VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE users_hashed_refresh_token (
    user_id CHAR(36) PRIMARY KEY,
    hashed_refresh_token VARCHAR(255) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE TABLE users_restaurant (
    user_id CHAR(36) PRIMARY KEY,
    nama VARCHAR (100),
    lokasi VARCHAR (100),
    menu JSON,
    link_gambar VARCHAR (255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);