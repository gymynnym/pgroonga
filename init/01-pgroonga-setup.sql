-- PGroongaエクステンションを有効化
CREATE EXTENSION IF NOT EXISTS pgroonga;

-- PGroongaトークナイザーを使用したテキスト検索設定を作成
-- 注: PGroongaはPostgreSQLのTEXT SEARCH CONFIGURATIONではなく、
--     独自のトークナイザーシステムを使用します
--
-- 日本語全文検索のサンプルテーブルとインデックスを作成
CREATE TABLE IF NOT EXISTS pgroonga_sample (
  id serial PRIMARY KEY,
  content text
);

-- PGroongaインデックスを作成（日本語トークナイザーを使用）
-- TokenMecabは日本語の形態素解析を行い、名詞、動詞、形容詞などを正確に認識します
-- normalizer='NormalizerNFKC150'で正規化も行います
CREATE INDEX IF NOT EXISTS idx_pgroonga_sample_content
  ON pgroonga_sample
  USING pgroonga (content)
  WITH (tokenizer='TokenMecab',
        normalizer='NormalizerNFKC150');

-- サンプルデータを挿入
INSERT INTO pgroonga_sample (content) VALUES
  ('PGroongaは日本語全文検索に対応しています'),
  ('名詞、動詞、形容詞を適切に認識します'),
  ('高速な検索が可能です')
ON CONFLICT DO NOTHING;

-- tech_articlesテーブルを作成
CREATE TABLE IF NOT EXISTS tech_articles (
  id SERIAL PRIMARY KEY,
  title TEXT,
  content TEXT
);

-- blog_postsテーブルを作成
CREATE TABLE IF NOT EXISTS blog_posts (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  tags TEXT[],
  author TEXT,
  published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  view_count INTEGER DEFAULT 0,
  lang VARCHAR(5) DEFAULT 'ja'
);
