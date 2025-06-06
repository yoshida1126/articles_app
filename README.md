# Articles
<ins></ins>

# 📘 概要
<ins></ins>

このアプリは、技術記事を投稿・共有するためのWebサービスです。  
ユーザー同士で記事を投稿し合い、コメント・いいね・フォローなどを通じて技術的な交流を図ることができます。

また、「お気に入りリスト機能」には特にこだわりがあり、  
**他のユーザーがどんな記事を保存しているのかを見ることができる設計**にしています。  
これは、「参考になる記事を見つけても、その投稿者が普段どんな記事を読んでいるか分からない」という  
自身の体験から生まれた発想です。

この仕組みによって、**知識や学びが人を通じて広がる体験**を提供し、  
ただの記事投稿にとどまらない、**コミュニティ的な価値**のあるサービスを目指しました。
 
レスポンシブ対応しているのでスマホからでもご覧いただけます。  
URL(https://articles.jp)  

<img width="1280" alt="Image" src="https://github.com/user-attachments/assets/85b6e565-3680-4863-9075-220ca085207f" />  

# 🔥 特に注力したポイント
<ins></ins>
- **画像ファイルの管理における工夫**
  - 記事の作成・更新時に使用される画像だけを適切に保存し、不要な画像ファイルは削除されるような仕組みを実装しました。
  - 一部、即時処理できない画像の削除に関しては、**Sidekiq を用いたバックグラウンドジョブで非同期的に処理**されるようにしています。

- **Fat Controller を避けるための設計**
  - 上記のような複雑なビジネスロジックはコントローラに直接書かず、**サービスクラスやモジュールに分離**することで、コードの可読性と保守性を高めています。

- **テストしやすさを意識した設計（DIの導入）**
  - モジュール内のメソッドでは **`Proc` を引数として受け取る形にし、依存性注入（DI）を導入**。
  - これにより、ユニットテストではモックを使用して処理の責務に限定したテストが可能となり、テスト容易性と柔軟性を両立しています。

## 💡 UI/UX面での工夫

- 記事作成時に **リアルタイムプレビュー機能** を実装し、Markdown記法の確認がしやすいよう工夫しました。
- **プロフィール画像のトリミング機能**を導入し、ユーザーが自分で画像の表示範囲を調整できるようにしました。
- 見た目だけでなく「使いやすさ」「迷わず操作できる導線」を意識し、**開発者自身が使っても快適なUI/UX** を意識しました。

# 使用技術
<ins></ins>
### 💻 開発環境 / バックエンド
- Ruby 3.2.2  
- Ruby on Rails 7.0.4.3   
- MySQL 8.1.0  
- Unicorn

### 🧪 テスト・静的解析
- RSpec   
- Rubocop  

### 🐳 開発環境構築・CI/CD
- Docker / Docker Compose  
- CircleCI

### ☁️ インフラ・クラウドサービス（AWS）
- AWS  
  - VPC  
  - EC2  
  - Route 53  (現在はコストを抑えるため、Cloudflareに移行しています)
  - S3  

# ⚙️ 機能一覧
<ins></ins>
- **お気に入り記事のリスト機能**
  - 気になる記事を自分の「お気に入りリスト」に保存して管理できます。
  - 特徴的なのは、**他ユーザーのリストも閲覧可能**な点で、  
    「このユーザーはどんな技術記事を参考にしているのか？」を知ることができ、  
    **知識の共有やインスピレーションの広がり**を促す設計になっています。
    - 今後は、**他のユーザーが作成したリストを自分のリストとして保存**できる機能を追加し、  
    より一層、**学びが人から人へと広がる仕組み**を目指したいと考えています。

- **ユーザー登録・ログイン機能（devise）**
  - 簡単で安全なユーザー認証を実装。

- **投稿機能**
  - 記事の投稿・編集機能を実装。現在は基本的なCRUD操作のみですが、今後は記事の**下書き保存**機能を追加し、編集を途中で中断できるように改善予定。

- **画像投稿機能**
  - プロフィール画像、記事のヘッダー画像、記事に貼る画像を投稿可能。
  - 特に記事に貼る画像に関しては、**ダイレクトアップロード**が可能で、**リアルタイムプレビュー**で確認できるようにしています。

- **いいね機能**
  - 記事への「いいね」機能を実装。今後、**ユーザーごとの「いいね」履歴を表示**する機能を追加して、ユーザーが過去に参考にした記事を振り返りやすくする予定です。

- **検索機能（ransack）**
  - 現在は`ransack`を使用して記事を検索できますが、今後、**検索対象が多いというサイトの特性を考慮して**、`ElasticSearch`に切り替える予定です。
  - ElasticSearchを利用することで、**インデックス型検索による高速かつ精度の高い検索**を実現し、より大規模なデータに対応可能にします。

- **ハッシュタグ機能（acts-as-taggable-on）**
  - 記事にタグを追加して、関連性の高い記事を簡単に見つけられるようにしました。

## 🧪 テスト
<ins></ins>
- **使用ツール**
  - RSpec（テストフレームワーク）
  - Capybara（システムテスト）
  - FactoryBot / Faker（テストデータ生成）

- **実施しているテストの種類**
  - **モデルの単体テスト**
    - バリデーションや関連付けの確認など、基本的なデータ整合性を担保するテストを記述。
  - **システムテスト**
    - ユーザーの一連の操作をブラウザ上で再現し、フロー全体の動作を確認。
  - **サービス層・モジュールの単体テスト**
    - 複雑なビジネスロジックはサービスクラス・モジュールに切り出し、それぞれに対して**責務を限定したユニットテスト**を実施。
    - 特にモジュールでは `Proc` を用いた **依存性注入（DI）** を行い、テスト時にはモックを使用することで外部依存を排除。**柔軟性・保守性・テスト容易性の向上**を意識しています。
  - **ビューやシステムテストを重視していましたが、最近はユニットテスト（モデル・サービス層）の重要性を認識し、責務を明確にした設計＋テストにシフトしています。**

