class ArticleCommentsController < ApplicationController
  before_action :logged_in_user

  def create
    # article_comment_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
    blob_signed_ids = JSON.parse(params[:article_comment][:blob_signed_ids])

    article = Article.find(params[:article_id])
    @article_comment = current_user.article_comments.new(article_comment_params)

    handle_comment_images_for_create(blob_signed_ids)

    @article_comment.article_id = article.id
    @article = Article.find(params[:article_id])
    @tags = @article.tag_counts_on(:tags)
    @comment = ArticleComment.new

    respond_to do |format|
      if @article_comment.save
        # 画像をアタッチするとupdated_atが更新されてしまうため、ビュー側で編集済みと表示させないための処理
        @article_comment.update(updated_at: @article_comment.created_at)
        format.html { redirect_to @article, @tags }
      else
        @error_comment = @article_comment
        format.html { redirect_to @article, @tags, @error_comment }
      end
      format.turbo_stream
    end
  end

  def destroy
    @article = Article.find(params[:article_id])
    @article_comment = ArticleComment.find(params[:id])
    return unless @article_comment.user == current_user

    respond_to do |format|
      if @article_comment.destroy
        format.html { redirect_to @article }
        format.turbo_stream
      end
    end
  end

  def edit
    @article_comment = ArticleComment.find(params[:id])
  end

  def update
    @article_comment = ArticleComment.find(params[:id])
    return unless @article_comment.user == current_user

    blob_signed_ids = JSON.parse(params[:article_comment][:blob_signed_ids])
    handle_comment_images_for_update(blob_signed_ids)

    @article = Article.find(params[:article_id])
    @tags = @article.tag_counts_on(:tags)

    respond_to do |format|
      if @article_comment.update(article_comment_params)
        @article_comment = ArticleComment.new
        format.html { redirect_to @article }
      else
        @error_comment = @article_comment
        format.html { redirect_to @article_comment, @error_comment }
      end
      format.turbo_stream
    end
  end

  private

  def article_comment_params
    p params[:article_comment]
    params[:article_comment].delete(:blob_signed_ids)
    params.require(:article_comment).permit(:comment, :created_at, :updated_at, comment_images: [])
  end

  def comment_images_attach(used_blob_signed_ids)
    return unless used_blob_signed_ids.present?

    used_blob_signed_ids.each do |blob_signed_id|
      blob = ActiveStorage::Blob.find_signed(blob_signed_id)
      @article_comment.comment_images.attach(blob)
    end
  end

  def extract_s3_urls(content)
    # S3のURLにマッチする正規表現
    # regex = /https:\/\/[a-zA-Z0-9\-]+\.s3\.[a-zA-Z0-9\-]+\.amazonaws\.com\/[^\s]+/
    regex = %r{rails/active_storage/blobs/[A-Za-z0-9-]+/[^\s]+} # ローカルの場合

    # contentからS3のURLを全て抽出し、配列で返す
    content.scan(regex)
  end

  def get_blob_signed_id_from_url(image_urls)
    return [] unless image_urls.present?

    used_blob_signed_ids = []
    image_urls.each do |url|
      # URLからS3のパス部分を取り出す（バケット名以降）
      # uri = URI.parse(url)
      # path = uri.path.sub(/^\//, '')  # 先頭のスラッシュを削除してパス部分を取得
      # 上記はS3のURL用の処理 以下はローカルの画像URLの処理

      # URLからパス部分を取り出す（/rails/active_storage/blobs/以降とファイル名より前の部分）
      # path = url.sub('/rails/active_storage/blobs/', '').split('/').first
      path = url.match(%r{rails/active_storage/blobs/([^/]+)/})[1]

      # ActiveStorage::Blobをパスで検索
      blob = ActiveStorage::Blob.find_signed(path)
      if blob
        used_blob_signed_ids.push(blob.signed_id)
      end
    end
    used_blob_signed_ids
  end

  def calculate_unused_blob_signed_ids(blob_signed_ids, attached_signed_ids, used_blob_signed_ids)
    combined_blob_signed_ids = if attached_signed_ids.present?
                                 blob_signed_ids.concat(attached_signed_ids)
                               else
                                 blob_signed_ids
                               end
    combined_blob_signed_ids - used_blob_signed_ids
  end

  def unused_blob_delete(unused_blob_signed_ids)
    unused_blob_signed_ids.each do |blob_signed_id|
      blob = ActiveStorage::Blob.find_signed(blob_signed_id)
      blob.purge_later if blob.present?
    end
  end

  def unused_blob_delete_later(unused_blob_signed_ids)
    unused_blob_signed_ids.each do |blob_signed_id|
      blob = ActiveStorage::Blob.find_signed(blob_signed_id)
      # blob に関連するアタッチメントを取得
      attachments = ActiveStorage::Attachment.where(blob_id: blob.id) if blob.present?

      if attachments
        # 各アタッチメントを purge して関連付けを削除
        attachments.each(&:purge)

        # アタッチメントがすべて削除された後、blob を削除 (ファイル自体も削除)
        blob.purge_later
      elsif blob.present?
        blob.purge_later
      end
    end
  end

  def handle_comment_images_for_create(blob_signed_ids)
    image_urls = extract_s3_urls(params[:article_comment][:comment])
    used_blob_signed_ids = get_blob_signed_id_from_url(image_urls)
    comment_images_attach(used_blob_signed_ids) # コメントに使われた画像のアタッチ処理

    unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使われていない画像のsigned_idの配列を取得
    unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像のpurge処理
  end

  def handle_comment_images_for_update(blob_signed_ids)
    attached_signed_ids = @article_comment.comment_images.map(&:signed_id)
    image_urls = extract_s3_urls(params[:article_comment][:comment])
    used_blob_signed_ids = get_blob_signed_id_from_url(image_urls)

    # 二重にアタッチしないようにするための処理
    used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids
    comment_images_attach(used_blob_signed_ids - used_attached_signed_ids)

    unused_blob_signed_ids = calculate_unused_blob_signed_ids(
      blob_signed_ids, attached_signed_ids, used_blob_signed_ids
    )
    unused_blob_delete_later(unused_blob_signed_ids) # 使われなかった画像のpurge処理
  end
end
