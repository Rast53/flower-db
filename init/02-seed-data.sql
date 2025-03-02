-- Вставка статусов заказа
INSERT INTO order_statuses (name, description) VALUES
('Новый', 'Заказ только что создан'),
('Подтвержден', 'Заказ подтвержден менеджером'),
('В процессе', 'Заказ находится в процессе сборки'),
('Готов к отправке', 'Заказ собран и готов к отправке'),
('Доставляется', 'Заказ в процессе доставки'),
('Выполнен', 'Заказ успешно доставлен'),
('Отменен', 'Заказ был отменен')
ON CONFLICT DO NOTHING;

-- Вставка тестовых категорий
INSERT INTO categories (name, description, image_url) VALUES
('Букеты', 'Готовые букеты на все случаи', '/images/categories/bouquets.jpg'),
('Розы', 'Классические и необычные розы', '/images/categories/roses.jpg'),
('Тюльпаны', 'Весенние тюльпаны разных цветов', '/images/categories/tulips.jpg'),
('Композиции', 'Оригинальные цветочные композиции', '/images/categories/compositions.jpg'),
('Комнатные растения', 'Растения для дома и офиса', '/images/categories/plants.jpg')
ON CONFLICT DO NOTHING;

-- Вставка тестовых продуктов
INSERT INTO products (category_id, name, description, price, discount_price, image_url, in_stock, featured) VALUES
(1, 'Букет "Весенняя нежность"', 'Нежный букет из весенних цветов', 2500.00, NULL, '/images/products/spring_bouquet.jpg', true, true),
(1, 'Букет "Яркий день"', 'Яркий разноцветный букет', 3000.00, 2700.00, '/images/products/bright_day.jpg', true, true),
(2, 'Красные розы 11 шт', 'Букет из 11 красных роз', 2200.00, NULL, '/images/products/red_roses.jpg', true, false),
(2, 'Белые розы 15 шт', 'Букет из 15 белых роз', 3000.00, NULL, '/images/products/white_roses.jpg', true, false),
(3, 'Тюльпаны микс 25 шт', 'Букет из 25 разноцветных тюльпанов', 2000.00, NULL, '/images/products/tulips_mix.jpg', true, false),
(4, 'Композиция "Лесная сказка"', 'Композиция из диких цветов с зеленью', 3500.00, 3200.00, '/images/products/forest_tale.jpg', true, true),
(5, 'Фикус Бенджамина', 'Комнатное растение в горшке', 1800.00, NULL, '/images/products/ficus.jpg', true, false),
(5, 'Орхидея Фаленопсис', 'Элегантная орхидея в горшке', 2500.00, NULL, '/images/products/orchid.jpg', true, true)
ON CONFLICT DO NOTHING; 