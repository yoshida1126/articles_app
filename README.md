*<ins>Articles</ins>

URL(https://articles.jp)

--概要--
  記事投稿サイト

--使用技術--
  Ruby 3.2.2
  Ruby on Rails 7.0.4.3 
  MySQL 8.1.0 
  unicorn
  RSpec 
  Rubocop

--機能一覧-- 
  •ユーザー登録、ログイン機能(devise) 
  •投稿機能
    記事の投稿・編集
    画像投稿(プロフィール画像・記事のヘッダー画像や記事に貼る画像　記事に貼る画像はダイレクトアップロードができる。)
  •マークダウン機能 (redcarpet)
  •いいね機能
  •コメント機能
  •フォロー機能
  •ページネーション機能 (will_paginate)
  •検索機能 (ransack)
  •ハッシュタグ機能 (acts-as-taggable-on)

  --テスト-- 
  •RSpec 
    単体テスト(model) 
    統合テスト(system) 
