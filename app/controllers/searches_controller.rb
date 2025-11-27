class SearchesController < ApplicationController
  # searchアクションは、サイト内の検索フォームから共通で呼び出されるため、
  # ApplicationController に定義しています。
  # 記事作成・編集ページなど検索フォームがないページでは使用されません。
end
