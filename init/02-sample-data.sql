-- 大量のサンプルデータを投入してページネーション検証用データを作成

-- blog_postsテーブルのデータをクリア
TRUNCATE blog_posts CASCADE;

-- ランダムな日本語記事データを生成（1000万件）
INSERT INTO blog_posts (title, content, tags, author, view_count, published_at)
SELECT 
  CASE (random() * 20)::int
    WHEN 0 THEN 'PostgreSQL' || i || 'の開発手法'
    WHEN 1 THEN 'データベース設計' || i || 'の基礎'
    WHEN 2 THEN '全文検索' || i || 'を活用したシステム'
    WHEN 3 THEN 'SQL最適化' || i || 'のテクニック'
    WHEN 4 THEN 'インデックス設計' || i || 'の実践'
    WHEN 5 THEN 'パフォーマンスチューニング' || i
    WHEN 6 THEN 'Docker' || i || 'による開発環境構築'
    WHEN 7 THEN 'マイクロサービス' || i || 'アーキテクチャ'
    WHEN 8 THEN 'クラウドネイティブ' || i || '開発'
    WHEN 9 THEN 'Kubernetes' || i || '実践ガイド'
    WHEN 10 THEN 'CI/CD' || i || 'パイプライン構築'
    WHEN 11 THEN 'セキュリティ対策' || i || 'の基本'
    WHEN 12 THEN 'ログ分析' || i || 'システム'
    WHEN 13 THEN '監視運用' || i || 'のベストプラクティス'
    WHEN 14 THEN 'バックアップ戦略' || i
    WHEN 15 THEN 'レプリケーション' || i || '設定'
    WHEN 16 THEN 'データ移行' || i || 'の手順'
    WHEN 17 THEN 'API開発' || i || 'の設計'
    WHEN 18 THEN 'フロントエンド' || i || '実装'
    ELSE 'バックエンド開発' || i
  END AS title,
  CASE (random() * 10)::int
    WHEN 0 THEN 'PGroongaを使用した日本語全文検索の実装方法について説明します。形態素解析により高精度な検索が可能になります。'
    WHEN 1 THEN 'データベース設計の基礎から応用まで、実践的な内容を解説します。正規化とパフォーマンスのバランスが重要です。'
    WHEN 2 THEN 'インデックス設計とクエリ最適化の手法を解説します。EXPLAIN ANALYZEを活用した分析方法も紹介します。'
    WHEN 3 THEN 'Docker Composeを使用したコンテナオーケストレーションについて説明します。開発環境の構築が簡単になります。'
    WHEN 4 THEN 'MeCabとJanomeを用いた形態素解析の実装例を紹介します。自然言語処理の基礎技術です。'
    WHEN 5 THEN 'Kubernetesを使用した本番環境でのデプロイ方法を解説します。スケーラビリティとレジリエンスを確保します。'
    WHEN 6 THEN 'CI/CDパイプラインの構築方法について実践的に説明します。自動テストとデプロイを実現します。'
    WHEN 7 THEN 'セキュリティ対策の基本から実践まで、包括的に解説します。脆弱性診断と対策が重要です。'
    WHEN 8 THEN 'PrometheusとGrafanaを使用した監視システムの構築方法を紹介します。可視化が運用の鍵です。'
    ELSE 'REST APIとGraphQL APIの設計パターンを比較検討します。用途に応じた選択が重要です。'
  END AS content,
  ARRAY[
    CASE (random() * 5)::int
      WHEN 0 THEN 'PostgreSQL'
      WHEN 1 THEN 'データベース'
      WHEN 2 THEN '全文検索'
      WHEN 3 THEN 'Docker'
      ELSE 'パフォーマンス'
    END,
    CASE (random() * 5)::int
      WHEN 0 THEN '開発'
      WHEN 1 THEN '運用'
      WHEN 2 THEN '設計'
      WHEN 3 THEN '最適化'
      ELSE 'セキュリティ'
    END
  ] AS tags,
  CASE (random() * 5)::int
    WHEN 0 THEN '山田太郎'
    WHEN 1 THEN '佐藤花子'
    WHEN 2 THEN '鈴木一郎'
    WHEN 3 THEN '田中美咲'
    ELSE '高橋健太'
  END AS author,
  (random() * 5000)::int AS view_count,
  CURRENT_TIMESTAMP - ((random() * 365)::int || ' days')::interval AS published_at
FROM generate_series(1, 10000000) AS i;

-- PGroongaインデックスを作成
CREATE INDEX IF NOT EXISTS idx_blog_posts_title_pgroonga ON blog_posts
  USING pgroonga (title)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

CREATE INDEX IF NOT EXISTS idx_blog_posts_content_pgroonga ON blog_posts
  USING pgroonga (content)
  WITH (tokenizer='TokenMecab', normalizer='NormalizerNFKC150');

-- ページネーション用の複合インデックス
CREATE INDEX IF NOT EXISTS idx_blog_posts_pagination ON blog_posts 
  (published_at DESC, id DESC);

-- 統計情報を更新
ANALYZE blog_posts;

