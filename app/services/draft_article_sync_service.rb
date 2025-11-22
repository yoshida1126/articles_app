class DraftArticleSyncService

  def initialize(draft:, action:, user: nil, params: [])
    @draft = draft
    @article = draft&.article
    @action = action
    @user = user
    @params = params
  end

  def call
    case @action
    when :autosave_draft
      handle_autosave_draft
    when :save_draft
      handle_save_draft
    when :update_draft
      handle_update_draft
    when :commit
      handle_commit
    when :update
      handle_update
    when :destroy
      handle_destroy
    else
      raise "Unknown action: #{@action}"
    end
  end

  private

  def handle_autosave_draft
    service = ArticleImageService.new(@user, @params, :autosave_draft)
    @draft, @params, remaining_mb, max_size = service.process

    @draft.editing = true

    @draft.assign_attributes(service.sanitized_article_draft_params(@params))

    return [@draft, remaining_mb, max_size]
  end

  def handle_save_draft
    service = ArticleImageService.new(@user, @params, :save_draft)
    @draft, @params = service.process

    @draft.editing = true

    @draft.assign_attributes(service.sanitized_article_draft_params(@params).except(:image))

    return @draft
  end

  def handle_update_draft
    service = ArticleImageService.new(@user, @params, :update_draft)
    @draft, @params = service.process

    @draft.editing = true

    @draft.assign_attributes(service.sanitized_article_draft_params(@params).except(:image))

    return @draft
  end

  def handle_commit
    to_published = @params[:article][:published]
    from_published = nil

    service = ArticleImageService.new(@user, @params, :commit)
    @article, @draft, @params = service.process

    begin
      ActiveRecord::Base.transaction do
        @draft.assign_attributes(service.sanitized_article_draft_params(@params).except(:image))
        @draft.save!
        @draft.reload

        sync_images
        @article.assign_attributes(service.sanitized_article_params(@params).except(:image))
        @article.save!
      end

      [@article, @draft, generate_notice_message(from_published, to_published), :success]
    rescue ActiveRecord::RecordInvalid => e
      [@article, @draft, e.record.errors.full_messages, :failure]
    end
  end

  def handle_update
    to_published = @params[:article][:published]

    if @draft.article.nil?
      from_published = nil
    else
      from_published = @article.published
    end

    service = ArticleImageService.new(@user, @params, :update)
    @article, @draft, @params = service.process

    begin
      ActiveRecord::Base.transaction do
        @draft.update!(service.sanitized_article_draft_params(@params).except(:image))
        @draft.reload

        sync_images
        @article.update!(service.sanitized_article_params(@params).except(:image))
      end

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

  def sync_images
    @article.image.attach(@draft.image.blob) if @draft.image.present?

    if @draft.article_images.attached?
      draft_ids   = @draft.article_images.blobs.map(&:id)
      article_ids = @article.article_images.blobs.map(&:id)

      remove_ids = article_ids - draft_ids
      add_ids    = draft_ids - article_ids

      @article.article_images.attachments.where(blob_id: remove_ids).each(&:purge_later) if remove_ids.present?

      add_ids.each do |id|
        blob = @draft.article_images.blobs.find(id)
        @article.article_images.attach(blob)
      end
    else
      @article.article_images.each(&:purge_later) if @article.article_images.present?
    end
  end

  def sync_draft_with_article
    @draft.assign_attributes(@article.attributes.except("id", "published", "created_at", "updated_at"))
    @draft.tag_list = @article.tag_list
    @draft.editing = false

    if @article.image.attached?
      @draft.image.attach(@article.image.blob) 
    else
      @draft.image.detach if @draft.image.attached?
    end

    if @article.article_images.attached?
      draft_ids   = @draft.article_images.blobs.map(&:id)
      article_ids = @article.article_images.blobs.map(&:id)

      remove_ids = draft_ids - article_ids
      add_ids    = article_ids - draft_ids
      
      @draft.article_images.attachments.where(blob_id: remove_ids).each(&:purge_later) if remove_ids.present?

      add_ids.each do |id|
        blob = @draft.article_images.blobs.find(id)
        @draft.article_images.attach(blob)
      end
    else
      @draft.article_images.each(&:purge_later) if @draft.article_images.present?
    end
  end
end
