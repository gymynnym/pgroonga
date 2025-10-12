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

-- tech_articlesのインデックスを作成
CREATE INDEX IF NOT EXISTS idx_tech_articles_title ON tech_articles
  USING pgroonga (title)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

CREATE INDEX IF NOT EXISTS idx_tech_articles_content ON tech_articles
  USING pgroonga (content)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

CREATE INDEX IF NOT EXISTS idx_tech_articles_all ON tech_articles
  USING pgroonga ((title || ' ' || content))
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

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

-- blog_postsのインデックスを作成
CREATE INDEX IF NOT EXISTS idx_blog_posts_title ON blog_posts
  USING pgroonga (title)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

CREATE INDEX IF NOT EXISTS idx_blog_posts_content ON blog_posts
  USING pgroonga (content)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

CREATE INDEX IF NOT EXISTS idx_blog_posts_tags ON blog_posts
  USING GIN (tags);

CREATE INDEX IF NOT EXISTS idx_blog_posts_view_count ON blog_posts (view_count DESC);

-- ページネーション用の複合インデックス
CREATE INDEX IF NOT EXISTS idx_blog_posts_pagination ON blog_posts 
  (published_at DESC, id DESC);

-- スコア順ページネーション用の複合インデックス
CREATE INDEX IF NOT EXISTS idx_score_date ON blog_posts 
  USING btree (view_count DESC, published_at DESC, id DESC);

-- 多言語検索用の部分インデックス
CREATE INDEX IF NOT EXISTS idx_blog_posts_content_ja ON blog_posts 
  USING pgroonga (content) 
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150')
  WHERE lang = 'ja';

CREATE INDEX IF NOT EXISTS idx_blog_posts_content_en ON blog_posts 
  USING pgroonga (content) 
  WITH (tokenizer='TokenBigram', normalizer='NormalizerNFKC150')
  WHERE lang = 'en';

CREATE INDEX IF NOT EXISTS idx_blog_posts_content_zh ON blog_posts 
  USING pgroonga (content) 
  WITH (tokenizer='TokenBigram', normalizer='NormalizerNFKC150')
  WHERE lang = 'zh';

-- articlesテーブルを作成（ノーマライザー例用）
CREATE TABLE IF NOT EXISTS articles (
  id SERIAL PRIMARY KEY,
  content TEXT
);

CREATE INDEX IF NOT EXISTS idx_with_normalizer ON articles
  USING pgroonga (content)
  WITH (
    tokenizer='TokenMecab',
    normalizer='NormalizerNFKC150'
  );
