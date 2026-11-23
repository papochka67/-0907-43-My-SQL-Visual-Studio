-- =====================================================
-- ShoeShop — схема БД (v1)
-- MySQL 8.x, кодировка utf8mb4
-- Порядок таблиц: справочники → users → products → orders → prodorders
-- =====================================================

CREATE DATABASE IF NOT EXISTS ShoeShop
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ShoeShop;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Чистим таблицы в обратном порядке зависимостей
DROP TABLE IF EXISTS prodorders;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS pvz;
DROP TABLE IF EXISTS orderstatus;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS suppliers;
DROP TABLE IF EXISTS manufacturers;
DROP TABLE IF EXISTS categories;

-- 1. Категории
CREATE TABLE categories (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Производители
CREATE TABLE manufacturers (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Поставщики
CREATE TABLE suppliers (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Роли
CREATE TABLE roles (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Статусы заказов
CREATE TABLE orderstatus (
    id   INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Пункты выдачи
CREATE TABLE pvz (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    postcode VARCHAR(10)  NOT NULL,
    city     VARCHAR(100) NOT NULL,
    street   VARCHAR(150) NOT NULL,
    house    VARCHAR(20)  NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Пользователи
CREATE TABLE users (
    id        INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(150) NOT NULL,
    login     VARCHAR(50)  NOT NULL UNIQUE,
    password  VARCHAR(100) NOT NULL,
    role_id   INT NOT NULL,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Товары
CREATE TABLE products (
    id              INT PRIMARY KEY AUTO_INCREMENT,
    article         VARCHAR(20)   NOT NULL UNIQUE,
    name            VARCHAR(200)  NOT NULL,
    unit            VARCHAR(20)   NOT NULL DEFAULT 'пара',
    price           DECIMAL(10,2) NOT NULL,
    discount        INT           NOT NULL DEFAULT 0,
    stock_qty       INT           NOT NULL DEFAULT 0,
    description     TEXT          NULL,
    photo           VARCHAR(200)  NULL,
    category_id     INT NOT NULL,
    manufacturer_id INT NOT NULL,
    supplier_id     INT NOT NULL,
    CONSTRAINT fk_products_category     FOREIGN KEY (category_id)     REFERENCES categories(id),
    CONSTRAINT fk_products_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id),
    CONSTRAINT fk_products_supplier     FOREIGN KEY (supplier_id)     REFERENCES suppliers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. Заказы
CREATE TABLE orders (
    id            INT PRIMARY KEY AUTO_INCREMENT,
    order_date    DATE NOT NULL,
    delivery_date DATE NULL,
    pvz_id        INT NOT NULL,
    user_id       INT NOT NULL,
    receive_code  VARCHAR(20) NOT NULL UNIQUE,
    status_id     INT NOT NULL,
    CONSTRAINT fk_orders_pvz    FOREIGN KEY (pvz_id)    REFERENCES pvz(id),
    CONSTRAINT fk_orders_user   FOREIGN KEY (user_id)   REFERENCES users(id),
    CONSTRAINT fk_orders_status FOREIGN KEY (status_id) REFERENCES orderstatus(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. Строки заказов
CREATE TABLE prodorders (
    id         INT PRIMARY KEY AUTO_INCREMENT,
    order_id   INT NOT NULL,
    product_id INT NOT NULL,
    qty        INT NOT NULL DEFAULT 1,
    CONSTRAINT fk_prodorders_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
    CONSTRAINT fk_prodorders_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
