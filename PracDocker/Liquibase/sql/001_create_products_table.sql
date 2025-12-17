-- Migration: 001_create_products_table
-- Author: student
-- Description: Создание таблицы products для магазина чак-чака

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    image_url VARCHAR(500)
);

