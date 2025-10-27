class DraftArticleSyncService
  include ArticleDraftParams::ArticleDraftParamsPermitter

  def initialize(draft:, action:, user: nil, params: [])
    @draft = draft
    @article = draft.article
    @action = action
    @user = user
    @params = params
  end

  def call
    case @action
    when :update_draft
      handle_update_draft
    when :update
      handle_update
    when :destroy
      handle_destroy
    else
      raise "Unknown action: #{@action}"
    end
  end

  private

  def handle_update_draft
    @draft.editing = true

    @draft
  end

  def handle_update
    service = ArticleImageService.new(@user, @params, :update)
    @draft, @params = service.process

    @draft.editing = false

    to_published = @params[:article][:published] == 'true'

    if @article.nil?
      @article = @user.articles.build(
        article_draft: @draft
      )
      from_published = nil

      @draft.article.image.attach(@draft.image&.blob)
    else
      from_published = @article.published
    end

    begin
      ActiveRecord::Base.transaction do
        @draft.update!(service.sanitized_article_draft_params(@params))
        @article.update!(service.sanitized_article_params(@params))
      end

      # 本日のヘッダー画像変更回数をインクリメント
      HeaderImageRateLimiterService.increment(@user.id) if @params[:article_draft][:image].present?

      [@article, @draft, generate_notice_message(from_published, to_published), :success]
    rescue ActiveRecord::RecordInvalid => e
      [@article, @draft, e.record.errors.full_messages, :failure]
    end
  end

  def generate_notice_message(from_published, to_published)
    if from_published.nil? && to_published
      notice = '新しい記事を投稿しました'
    elsif !from_published && !to_published
      notice = '非公開記事を編集しました'
    elsif from_published && !to_published
      notice = '非公開記事として編集しました'
    elsif !from_published && to_published
      notice = '非公開記事を公開しました'
    else from_published && to_published
      notice = '記事を編集しました'
    end
  end

  def handle_destroy
    if @article
      sync_draft_with_article
      @draft.save!
    else
      @draft.destroy
    end
  end

  def sync_draft_with_article
    @draft.title = @article.title
    @draft.image.attach(@article.image.blob) if @article.image.attached?
    @draft.tag_list = @article.tag_list
    @draft.content = @article.content
    @draft.editing = false

    @draft.article_images.detach

    @article.article_images.each do |image|
      @draft.article_images.attach(image.blob)
    end
  end
end