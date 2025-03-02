-- Функция для автоматического обновления времени изменения
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Триггер для таблицы categories
DROP TRIGGER IF EXISTS update_categories_modtime ON categories;
CREATE TRIGGER update_categories_modtime
BEFORE UPDATE ON categories
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Триггер для таблицы products
DROP TRIGGER IF EXISTS update_products_modtime ON products;
CREATE TRIGGER update_products_modtime
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Триггер для таблицы users
DROP TRIGGER IF EXISTS update_users_modtime ON users;
CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_modified_column();

-- Триггер для таблицы orders
DROP TRIGGER IF EXISTS update_orders_modtime ON orders;
CREATE TRIGGER update_orders_modtime
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_modified_column(); 