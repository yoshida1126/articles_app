class ArticlesController < ApplicationController
  before_action :logged_in_user, only: %i[new create edit update destroy]
  before_action :correct_user, only: %i[edit update destroy]

  def index; end

  def show
    # 記事のページの情報を取得する
    @article = Article.find(params[:id])
    @tags = @article.tag_counts_on(:tags)
    @article_comment = ArticleComment.new
    return unless current_user # ログインしていない時お気に入りのリストは必要ないのでここで情報を返す

    @favorite_article_lists = current_user.favorite_article_lists
    @favorite = Favorite.new
  end

  def new
    @article = Article.new
  end

  def create
    # article_paramsメソッドにより取り出せなくなる前にblob_signed_idsを取得
    blob_signed_ids = JSON.parse(params[:article][:blob_signed_ids])

    @article = current_user.articles.build(image_resize(article_params))
    @article.image.attach(article_params[:image]) # ヘッダー画像のアタッチ処理

    image_urls = extract_s3_urls(params[:article][:content]) # 画像が保存されている場所のURLを取得
    used_blob_signed_ids = get_blob_signed_id_from_url(image_urls) # URLを元に使われている画像のblob_signed_idの配列を取得
    article_images_attach(used_blob_signed_ids) # 記事本文に使われた画像のアタッチ処理

    unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids # 使われていない画像のblob_signed_idの配列を取得
    unused_blob_delete(unused_blob_signed_ids) # 使われなかった画像のpurge処理

    if @article.save
      flash[:notice] = '記事を作成しました。'
      redirect_to current_user
    else
      render 'articles/new', status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user
    @article = @user.articles.find(params[:id])
    # @blob_signed_ids = @article.article_images.map do |image|
    #   image.blob.signed_id
    # end.to_json
  end

  def update
    blob_signed_ids = JSON.parse(params[:article][:blob_signed_ids])

    attached_signed_ids = @article.article_images.map do |image|
      image.blob.signed_id
    end
    
    image_urls = extract_s3_urls(params[:article][:content]) # 画像が保存されている場所のURLを取得
    used_blob_signed_ids = get_blob_signed_id_from_url(image_urls) # URLを元に使われている画像のblob_signed_idの配列を取得

    used_attached_signed_ids = attached_signed_ids & used_blob_signed_ids # 編集後にも使われているアタッチ済みの画像を抽出
    article_images_attach(used_blob_signed_ids - used_attached_signed_ids) # 記事の編集により追加された画像のアタッチ処理

    if attached_signed_ids.present?
      unused_blob_signed_ids = (blob_signed_ids.concat(attached_signed_ids)) - used_blob_signed_ids # 使われていない画像のblob_signed_idの配列を取得
      unused_blob_delete_later(unused_blob_signed_ids) # 使われなかった画像や、消された画像のpurge処理
    else
      unused_blob_signed_ids = blob_signed_ids - used_blob_signed_ids
      unused_blob_delete_later(unused_blob_signed_ids)
    end

    if article_params[:image]
      @article.image.purge
      params = image_resize(article_params)
      @article.image.attach(params[:image])
    end

    if @article.update(article_params)
      flash[:notice] = '記事を編集しました。'
      redirect_to current_user, status: :see_other
    else
      render 'articles/edit', status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    flash[:notice] = '記事を削除しました。'
    redirect_to current_user, status: :see_other
  end

  private

  def article_params
    blob_signed_ids = params[:article][:blob_signed_ids]
    params[:article].delete(:blob_signed_ids)

    params.require(:article).permit(:title, :content, :image, :tag_list, article_images: [])
  end

  def correct_user
    # 記事の作成者が、現在ログイン中のユーザーであるかを確認
    @article = current_user.articles.find_by(id: params[:id])
    return unless @article.nil?

    flash[:alert] = "#{current_user.name}さんの記事以外は編集できません。"
    redirect_to root_url, status: :see_other
  end

  def image_resize(params)
    if params[:image]
      params[:image].tempfile = ImageProcessing::MiniMagick.source(params[:image].tempfile).resize_to_limit(1024,
                                                                                                            1024).call
    end
    params
  end

  def article_images_attach(used_blob_signed_ids)
    unless used_blob_signed_ids.empty?
      used_blob_signed_ids.each do |blob_signed_id|
        blob = ActiveStorage::Blob.find_signed(blob_signed_id)
        @article.article_images.attach(blob)
      end
    end
  end

  def extract_s3_urls(content)
    # S3のURLにマッチする正規表現
    # regex = /https:\/\/[a-zA-Z0-9\-]+\.s3\.[a-zA-Z0-9\-]+\.amazonaws\.com\/[^\s]+/
    regex = /\/rails\/active_storage\/blobs\/[A-Za-z0-9\-]+\/[^\s]+/ #ローカルの場合

    # contentからS3のURLを全て抽出し、配列で返す
    content.scan(regex)
  end

  def get_blob_signed_id_from_url(image_urls)
    used_blob_signed_ids = []
    image_urls.each do |url|
      # URLからS3のパス部分を取り出す（バケット名以降）
      # uri = URI.parse(url)
      # path = uri.path.sub(/^\//, '')  # 先頭のスラッシュを削除してパス部分を取得
      # 上記はS3のURL用の処理 以下はローカルの画像URLの処理

      # URLからパス部分を取り出す（/rails/active_storage/blobs/以降とファイル名より前の部分）
      path = url.sub("/rails/active_storage/blobs/", '').split("/").first

      # ActiveStorage::Blobをパスで検索
      blob = ActiveStorage::Blob.find_signed(path)
      if blob
        used_blob_signed_ids.push(blob.signed_id)
      end
    end
    used_blob_signed_ids
  end

  def unused_blob_delete(unused_blob_signed_ids)
    unused_blob_signed_ids.each do |blob_signed_id|
      blob = ActiveStorage::Blob.find_signed(blob_signed_id)
      blob.purge_later if blob
    end
  end

  def unused_blob_delete_later(unused_blob_signed_ids)
    unused_blob_signed_ids.each do |blob_signed_id|
      blob = ActiveStorage::Blob.find_signed(blob_signed_id)
      # blob に関連するアタッチメントを取得
      attachments = ActiveStorage::Attachment.where(blob_id: blob.id) if blob
      
      if attachments
        # 各アタッチメントを purge して関連付けを削除
        attachments.each do |attachment|
          attachment.purge
        end
  
        # アタッチメントがすべて削除された後、blob を削除 (ファイル自体も削除)
        blob.purge_later
      else
        blob.purge_later if blob
      end
    end
  end
end
