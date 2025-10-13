# app/services/trend_tag_service.rb
class TrendTagService
  def initialize(tags, limit: 15, min_articles: 10)
    @tags = tags
    @limit = limit
    @min_articles = min_articles
  end

  def call
    # タグ名のみを配列で抽出（後の検索用）
    tag_names = @tags.map(&:name)

    # 各タグに関連する記事を1回のクエリで取得（N+1回避のため includes(:tags) を使用）
    # タグ付けされた記事をまとめて取得し、最大で 15 * タグ数 分取得
    articles = Article
      .published
      .joins(:tags)
      .where(tags: { name: tag_names })
      .includes(:tags)
      .limit(@limit * tag_names.size)

    # タグ名ごとに記事を分けて格納するためのハッシュ（自動初期化付き）  
    articles_by_tag = Hash.new { |h, k| h[k] = [] }
    articles.each do |article|
      article.tags.each do |tag|
        # 必要なタグだけに限定して格納（念のためフィルタリング）
        articles_by_tag[tag.name] << article if tag_names.include?(tag.name)
      end
    end

    # 各タグに対して、記事数が10件以上ある場合のみセクションとして表示
    # 表示用の構造体（ハッシュ）を作成
    @tags.map do |tag|
      tagged_articles = articles_by_tag[tag.name].uniq.first(@limit)
      next if tagged_articles.size < @min_articles

      {
        name: tag.name,
        tag: tag,
        articles: tagged_articles
      }
    end.compact # nilを除外（10件未満で next されたもの）
  end
end
