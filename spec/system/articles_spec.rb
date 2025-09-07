require 'rails_helper'

RSpec.describe 'Articles', type: :system, js: true do

  describe '#show' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'user login(article user)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがあること' do
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}", exact: true
        expect(page).to have_css '.dli-more-v'
      end

      it '記事の編集ページへのリンクがあること' do
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}", exact: true
        click_link 'option'
        expect(page).to have_content '記事を編集'
      end

      it '記事を削除するリンクがあること' do
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}", exact: true
        click_link 'option'
        expect(page).to have_content '記事を削除'
      end
    end

    context 'user login(other user)' do
      before do
        sign_in other_user
        visit root_path
        visit "/articles/#{article.id}"
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがないこと' do
        expect(page).to_not have_css '#option'
      end
    end

    context 'as a non logged in user' do
      before do
        visit root_path
        visit "/articles/#{article.id}"
      end

      it '記事の編集や削除のリンクを表示するケバブメニューがないこと' do
        expect(page).to_not have_css '#option'
      end
    end
  end

  describe '#new' do
    let(:user) { FactoryBot.create(:user) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        click_link '投　稿', match: :first
      end

      it '記事投稿ページにアクセスできること' do
        expect(page).to have_content '記事投稿フォーム'
      end
    end

    context 'as a non logged in user' do
      it 'ログインページにリダイレクトされること' do
        visit '/articles/new'
        expect(current_path).to eq login_path
      end
    end
  end

  describe '#create' do
    let!(:user) { FactoryBot.create(:user) }

    context 'as a logged in user(input correct article informations)' do
      before do
        sign_in user
        visit 'articles/new'
        fill_in 'article[title]', with: 'Article Title'
        fill_in 'article[content]', with: 'Article content'
        fill_in 'article[tag_list]', with: 'article'
        attach_file 'article[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article[images][]', 'spec/fixtures/map.png', visible: false
        click_button '投　稿'
      end

      it '記事の投稿に成功すること' do
        expect(page).to have_selector 'div.alert-success'
      end

      it 'プロフィールページの記事一覧に投稿したヘッダー画像があること' do
        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'プロフィールページの記事一覧に投稿した記事のタイトルがあること' do
        sleep 0.2
        expect(page).to have_content('Article Title')
      end

      it '投稿した記事の画像が表示されていること' do
        click_link 'Article Title'
        expect(page).to have_selector "img[alt='map.png']"
      end
    end

    context 'as a logged in user(input wrong article informations)' do
      before do
        sign_in user
        visit 'articles/new'
      end

      it 'タイトルを入力していないと投稿できないこと' do
        fill_in 'article[title]', with: ''
        fill_in 'article[content]', with: 'Article content'
        fill_in 'article[tag_list]', with: 'article'
        click_button '投　稿'
        expect(page).to_not have_selector 'div.alert-success'
      end

      it '記事の内容が空だと投稿できないこと' do
        fill_in 'article[title]', with: 'Article Title'
        fill_in 'article[content]', with: ''
        fill_in 'article[tag_list]', with: 'article'
        click_button '投　稿'
        expect(page).to_not have_selector 'div.alert-success'
      end

      it 'タグを付けないと投稿できないこと' do
        fill_in 'article[title]', with: 'Article Title'
        fill_in 'article[content]', with: 'Article Content'
        fill_in 'article[tag_list]', with: ''
        click_button '投　稿'
        expect(page).to_not have_selector 'div.alert-success'
      end
    end
  end

  describe '#edit' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        sleep 0.2
        click_link "#{article.title}"
        click_link 'option', match: :first, exact: true
        click_link '記事を編集'
      end

      it '記事の編集ページにアクセスできること' do
        sleep 0.2
        expect(page).to have_content '記事編集フォーム'
      end
    end

    context 'as a logged in other user' do
      before do
        sign_in other_user
        visit "articles/#{article.id}/edit"
      end

      it '記事の編集ページにアクセスできないこと' do
        expect(current_path).to eq root_path
      end

      it 'フラッシュメッセージが表示されること' do
        expect(page).to have_selector 'div.alert-danger'
      end
    end

    context 'as a non logged in user' do
      it '記事の編集ページにアクセスできないこと' do
        visit "articles/#{article.id}/edit"
        expect(current_path).to eq login_path
      end
    end
  end

  describe '#update' do
    let(:user) { FactoryBot.create(:user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user(input correct article informations)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        sleep 0.5
        click_link "#{article.title}"
        click_link 'option', match: :first, exact: true
        click_link '記事を編集'
        fill_in 'article[title]', with: 'Article Edit Title'
        fill_in 'article[content]', with: 'Article Edit content'
        fill_in 'article[tag_list]', with: 'article'
        attach_file 'article[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article[content][]', 'spec/fixtures/map.png', visible: false
        click_button '編　集'
      end

      it '記事の編集に成功すること' do
        sleep 0.5
        expect(page).to have_selector '.alert-success'
      end

      it 'プロフィールページの記事一覧ページに編集した記事のタイトルがあること' do
        sleep 1
        expect(page).to have_content 'Article Edit Title'
      end
  
      it '記事のタイトルが変わっていること' do
        click_link 'Article Edit Title'
        expect(page).to have_content 'Article Edit content'
      end

      it '編集で追加したヘッダー画像があること' do
        sleep 1
        click_link 'Article Edit Title'
        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        click_link 'Article Edit Title'
        sleep 1
        expect(page).to have_selector "img[src$='map.png']"
      end
    end

    context 'as a logged in user(input wrong article informations)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        sleep 0.2
        click_link "#{article.title}"
        click_link 'option', match: :first, exact: true
        click_link '記事を編集'
      end

      it '記事のタイトルが空だと編集できないこと' do
        fill_in 'article[title]', with: ''
        expect(page).to_not have_selector 'div.alert-success'
      end

      it '記事の内容が空だと編集できないこと' do
        fill_in 'article[content]', with: ''
        expect(page).to_not have_selector 'div.alert-success'
      end

      it '記事のタグが空だと編集できないこと' do
        fill_in 'article[tag_list]', with: ''
        expect(page).to_not have_selector 'div.alert-success'
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article) { Article.create(title: 'test', content: 'test', tag_list: 'test', user_id: user.id) }

    context 'as a logged in user(correct user)' do
      before do
        sign_in user
        visit root_path
        click_link 'プロフィール画像', match: :first, exact: true
        click_link 'プロフィール', match: :first, exact: true
        click_link "#{article.title}", exact: true
        click_link 'option'
        @article_title = article.title
      end

      it '削除した記事がプロフィールページの記事一覧にないこと' do
        page.accept_confirm do
          click_link '記事を削除'
        end
        expect(page).to_not have_content '@article_title'
      end

     it '確認ダイアログでキャンセルを選択すると記事が削除されないこと' do
        page.dismiss_confirm do
          click_link '記事を削除'
        end
        expect(current_path).to eq "/articles/#{article.id}"
      end
    end
  end
end