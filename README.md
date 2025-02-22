# Articles
<ins></ins>

記事の投稿サイトです。  
レスポンシブ対応しているのでスマホからでもご覧いただけます。  
URL(https://articles.jp)  

<img width="1280" alt="Image" src="https://github.com/user-attachments/assets/85b6e565-3680-4863-9075-220ca085207f" />  

# 使用技術
<ins></ins>
  * Ruby 3.2.2  
  * Ruby on Rails 7.0.4.3   
  * MySQL 8.1.0  
  * unicorn  
  * RSpec   
  * Rubocop 
  * Docker / Docker-compose  
  * CircleCi (導入段階)  
  * AWS  
      * VPC  
      * EC2 
      * Route53   
      * S3 

# 機能一覧
<ins></ins>
  * ユーザー登録、ログイン機能(devise) 
  * 投稿機能
      * 記事の投稿・編集  
      * 画像投稿(プロフィール画像・記事のヘッダー画像や記事に貼る画像　記事に貼る画像はダイレクトア ップロードができる。)  
  * マークダウン機能 (redcarpet)  
  * いいね機能  
  * コメント機能  
  * フォロー機能  
  * ページネーション機能 (will_paginate)  
  * 検索機能 (ransack)  
  * ハッシュタグ機能 (acts-as-taggable-on)  

# テスト
<ins></ins>
  * RSpec   
      * 単体テスト(model)  
      * 統合テスト(system)   
