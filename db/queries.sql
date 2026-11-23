-- =====================================================
-- ShoeShop — запросы для WinForms-приложения (v1)
-- Все параметры помечены знаком «?» — их подставляет
-- MySqlCommand.Parameters.AddWithValue(...) в C#.
-- =====================================================

USE ShoeShop;
SET NAMES utf8mb4;

-- -----------------------------------------------------
-- 1. Авторизация пользователя по логину и паролю.
--    Возвращает ФИО и роль; если строки нет — вход не выполнен.
--    В C#: cmd.Parameters — login, password.
-- -----------------------------------------------------
SELECT u.id,
       u.full_name,
       r.name AS role_name
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ?
  AND u.password = ?;

-- -----------------------------------------------------
-- 2. Каталог товаров: JOIN с категорией, производителем, поставщиком.
--    Используется в D05 для отображения списка.
-- -----------------------------------------------------
SELECT p.id,
       p.article,
       p.name,
       p.unit,
       p.price,
       p.discount,
       p.stock_qty,
       p.description,
       p.photo,
       c.name  AS category_name,
       m.name  AS manufacturer_name,
       s.name  AS supplier_name
FROM products p
JOIN categories    c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers     s ON s.id = p.supplier_id
ORDER BY p.name;

-- -----------------------------------------------------
-- 3. Поиск + фильтр по поставщику + сортировка по остатку.
--    Используется в D06 (поиск, фильтр, сортировка).
--    Параметры: search (LIKE), supplier_id, направление сортировки.
-- -----------------------------------------------------
SELECT p.id,
       p.article,
       p.name,
       p.price,
       p.discount,
       p.stock_qty,
       s.name AS supplier_name
FROM products p
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%')
  AND p.supplier_id = ?
ORDER BY p.stock_qty ASC;
-- при необходимости ASC заменить на DESC — направление задаётся в C#.

-- -----------------------------------------------------
-- 4. Справочники для ComboBox (D05/D06/D07).
--    Каждый запрос подгружает id и name для выпадающих списков.
-- -----------------------------------------------------
SELECT id, name FROM categories    ORDER BY name;
SELECT id, name FROM manufacturers ORDER BY name;
SELECT id, name FROM suppliers     ORDER BY name;

-- -----------------------------------------------------
-- 5. Добавление нового товара (D07 + D08).
--    Все параметры передаются из формы товара.
-- -----------------------------------------------------
INSERT INTO products
    (article, name, unit, price, discount, stock_qty,
     description, photo, category_id, manufacturer_id, supplier_id)
VALUES
    (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- -----------------------------------------------------
-- 6. Открытие карточки товара и сохранение изменений.
-- 6.1. Загрузить товар по id.
-- -----------------------------------------------------
SELECT p.*,
       c.name AS category_name,
       m.name AS manufacturer_name,
       s.name AS supplier_name
FROM products p
JOIN categories    c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers     s ON s.id = p.supplier_id
WHERE p.id = ?;

-- 6.2. Обновить товар.
-- -----------------------------------------------------
UPDATE products
SET article         = ?,
    name            = ?,
    unit            = ?,
    price           = ?,
    discount        = ?,
    stock_qty       = ?,
    description     = ?,
    photo           = ?,
    category_id     = ?,
    manufacturer_id = ?,
    supplier_id     = ?
WHERE id = ?;

-- -----------------------------------------------------
-- 7. Проверка перед удалением товара (D10).
--    Если count > 0 — удаление запрещено: товар есть в строках заказов.
-- -----------------------------------------------------
SELECT COUNT(*) AS used_in_orders
FROM prodorders
WHERE product_id = ?;

-- -----------------------------------------------------
-- 8. Удаление товара (D10).
--    При наличии связанных строк prodorders удаление будет
--    отклонено FK (ON DELETE NO ACTION) — приложение покажет D11-сообщение.
-- -----------------------------------------------------
DELETE FROM products
WHERE id = ?;
