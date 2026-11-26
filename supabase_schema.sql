-- ============================================================
--   Star Harlen — Supabase Schema
--   Выполните этот скрипт в Supabase SQL Editor
--   (Dashboard → SQL Editor → New query → вставьте → Run)
-- ============================================================

-- Таблица публичных данных сайта (профиль, разделы, посты, тарифы, тексты, тема)
-- Читают: все (анонимы видят сайт). Пишут: только авторизованный админ.
CREATE TABLE IF NOT EXISTS site_public (
    id INT PRIMARY KEY DEFAULT 1,
    data JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Таблица приватных данных (заказы с контактами клиентов)
-- Читают/пишут: только авторизованный админ.
CREATE TABLE IF NOT EXISTS site_private (
    id INT PRIMARY KEY DEFAULT 1,
    data JSONB NOT NULL DEFAULT '{}'::jsonb,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Создаём строки по умолчанию
INSERT INTO site_public (id, data) VALUES (1, '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO site_private (id, data) VALUES (1, '{}'::jsonb)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
--   Row Level Security (RLS)
-- ============================================================

-- site_public: все могут читать, только авторизованные могут писать
ALTER TABLE site_public ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_site_public" ON site_public;
CREATE POLICY "read_site_public" ON site_public
    FOR SELECT TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "write_site_public" ON site_public;
CREATE POLICY "write_site_public" ON site_public
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- site_private: только авторизованные могут читать и писать
ALTER TABLE site_private ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_site_private" ON site_private;
CREATE POLICY "read_site_private" ON site_private
    FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "write_site_private" ON site_private;
CREATE POLICY "write_site_private" ON site_private
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ============================================================
--   Готово!
--   После выполнения SQL:
--   1. Откройте сайт (index.html)
--   2. Нажмите Ctrl+Shift+A (или «⚙ Админ-панель» в футере)
--   3. Введите ваш email → «Отправить ссылку»
--   4. Проверьте почту → кликните по ссылке в письме
--   5. Вы автоматически войдёте в админку
--
--   Первый вход создаст аккаунт автоматически.
--   После первого входа можно отключить публичную регистрацию:
--   Authentication → Sign In / Up → Disable "Allow new users to sign up"
--   (ваши magic links всё равно будут работать)
-- ============================================================
