require 'rails_helper'

RSpec.describe 'ArticleDrafts', type: :system, js: true do

  describe '#preview' do
    let!(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

    context 'as a logged in user' do
      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)
      end

      it '下書きの編集や削除のリンクを表示するケバブメニューがあること' do 
        expect(page).to have_css('.dli-more-v')
      end

      it '下書きの編集ページへのリンクがあること' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('下書きを編集')
      end

      it '下書きを削除するリンクがあること' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('下書きを削除')
      end
    end

    context 'as a logged in user(other user)' do
      before do
        sign_in other_user
        visit preview_user_article_draft_path(user, article_draft)
      end

      it 'ルートパスにリダイレクトされること' do
        expect(current_path).to eq root_path
      end
    end
  end

  describe '#new' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'as a logged in user' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
      end

      it 'アクセスできていること' do
        expect(current_path).to eq new_user_article_draft_path(user)
      end
    end

    context 'as a logged in user(other user)' do
      before do
        sign_in other_user
        visit new_user_article_draft_path(user)
      end

      it 'ルートパスにリダイレクトされること' do
        expect(current_path).to eq root_path
      end
    end
  end

  describe '#autosave_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'autosave from new draft path' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
        fill_in 'article_draft[title]', with: 'Article Autosave Title'
        fill_in 'article_draft[content]', with: "Article content\n"
        fill_in 'article_draft[tag_list]', with: 'autosavearticle'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[images][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        page.accept_confirm do
          visit drafts_user_path(user)
        end
      end

      it '下書き一覧にオートセーブされた下書きのタイトルがあること' do
        expect(page).to have_content('Article Autosave Title')
      end

      it 'オートセーブされた下書きの内容が失われていないこと' do
        click_link 'Article Autosave Title'

        expect(page).to have_content('Article Autosave Title')
        expect(page).to have_content('autosavearticle')
        expect(page).to have_selector("img[src$='earth.png']")
        expect(page).to have_selector("img[alt='map.png']")
      end
    end

    context 'autosave from edit draft path' do
      let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit new_user_article_draft_path(user)
        fill_in 'article_draft[title]', with: 'Article Autosave Title'
        fill_in 'article_draft[content]', with: "Article content\n"
        fill_in 'article_draft[tag_list]', with: 'autosavearticle'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[images][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        page.accept_confirm do
          visit drafts_user_path(user)
        end
      end

      it '下書き一覧にオートセーブされた下書きのタイトルがあること' do
        expect(page).to have_content('Article Autosave Title')
      end

      it 'オートセーブされた下書きの内容が失われていないこと' do
        click_link 'Article Autosave Title'

        expect(page).to have_content('Article Autosave Title')
        expect(page).to have_content('autosavearticle')
        expect(page).to have_selector("img[src$='earth.png']")
        expect(page).to have_selector("img[alt='map.png']")
      end
    end
  end

  describe '#save_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'save as draft' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
        fill_in 'article_draft[title]', with: 'Article Title'
        fill_in 'article_draft[content]', with: 'Article content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[images][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '下書きの保存に成功すること' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'プロフィールページの下書き記事一覧に保存したヘッダー画像があること' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'プロフィールページの下書き記事一覧に保存した下書きのタイトルがあること' do
        expect(page).to have_content('Article Title')
      end

      it '保存した下書きの画像が表示されていること' do
        expect(page).to have_link('Article Title')
        click_link 'Article Title'

        expect(page).to have_selector("img[alt='map.png']")
      end
    end
  end

  describe '#commit' do
    let(:user) { FactoryBot.create(:user) }

    context 'submit as a published article' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
        click_button '公開'
        fill_in 'article_draft[title]', with: 'Article Title'
        fill_in 'article_draft[content]', with: 'Article content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[images][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の投稿に成功すること' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'プロフィールページの投稿記事一覧に保存したヘッダー画像があること' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'プロフィールページの投稿記事一覧に投稿した記事のタイトルがあること' do
        expect(page).to have_content('Article Title')
      end

      it '投稿した記事の画像が表示されていること' do
        expect(page).to have_link('Article Title')
        click_link 'Article Title'

        expect(page).to have_selector("img[alt='map.png']")
      end

      it 'プロフィールページの下書き記事一覧に投稿した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Title')
      end
    end

    context 'submit as a private article' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
        click_button '公開'
        find('label', text: '自分だけが見られる').click
        fill_in 'article_draft[title]', with: 'Article Title'
        fill_in 'article_draft[content]', with: 'Article content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[images][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '非公開記事の投稿に成功すること' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'プロフィールページの非公開記事一覧に投稿したヘッダー画像があること' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'プロフィールページの非公開記事一覧に投稿した記事のタイトルがあること' do
        expect(page).to have_content('Article Title')
      end

      it '投稿した非公開記事の画像が表示されていること' do
        expect(page).to have_link('Article Title')
        click_link 'Article Title'

        expect(page).to have_selector("img[alt='map.png']")
      end

      it 'プロフィールページの下書き一覧に投稿した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Title')
      end
    end
  end

  describe '#edit' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'as a logged in user(accessing the edit page from an article page)' do
      let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user)}

      before do
        sign_in user
        visit article_path(article)

        expect(page).to have_link('option', visible: true)
        click_link 'option', match: :first, exact: true

        expect(page).to have_link('記事を編集', visible: true)
        click_link '記事を編集'
      end

      it '記事の編集ページにアクセスできること' do
        expect(current_path).to eq edit_user_article_draft_path(user, article_draft)
      end
    end

    context 'as a logged in user(accessing the edit page from an article page)' do
      let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)

        expect(page).to have_link('option', visible: true)
        click_link 'option', match: :first, exact: true

        expect(page).to have_link('下書きを編集', visible: true)
        click_link '下書きを編集'
      end

      it '下書きの編集ページにアクセスできること' do
        expect(current_path).to eq edit_user_article_draft_path(user, article_draft)
      end
    end

    context 'as a logged in other user' do
      let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

      before do
        sign_in other_user
        visit edit_user_article_draft_path(user, article_draft)
      end

      it '記事の編集ページにアクセスできないこと' do
        expect(current_path).to eq root_path
      end

      it 'フラッシュメッセージが表示されること' do
        expect(page).to have_selector('div.alert-danger')
      end
    end
  end

  describe '#update_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'editing a posted article draft' do
      let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)

        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の編集に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '下書き記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it '下書き記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end

      it '編集元の記事のタイトルが変わってないこと' do
        find('.tab-type .tab', text: '投稿記事').click

        expect(page).to_not have_content('Article Edit Title')
      end

      it '編集元の記事の内容が変わってないこと' do
        find('.tab-type .tab', text: '投稿記事').click
        click_link 'test article'

        expect(page).to_not have_content('Article Edit content')
      end
    end

    context 'editing a draft' do
      let!(:article) { Article.create(title: 'test article', content: 'test', tag_list: 'test', user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)

        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '下書きの編集に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '下書き記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it '下書き記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryBot.create(:user) }

    context'post a draft' do
      let(:article_draft) { FactoryBot.create(:article_draft, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)
        click_button '公開'
        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の公開に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '投稿記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it '記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'プロフィールページの下書き一覧に編集した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'update of posted article' do
      let!(:article) { FactoryBot.create(:article, user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)
        click_button '更新'
        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の更新に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '投稿記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it '記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'プロフィールページの下書き一覧に編集した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'update the post as a private post' do
      let!(:article) { FactoryBot.create(:article, user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)
        click_button '更新'
        find('label', text: '自分だけが見られる').click
        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の更新に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '非公開記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end

      it '記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'プロフィールページの下書き一覧に編集した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'update a private article as a public article' do
      let!(:private_article) { FactoryBot.create(:article, user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: private_article, user: user) }

      before do
        sign_in user
        visit edit_user_article_draft_path(user, article_draft)
        click_button '更新'
        fill_in 'article_draft[title]', with: 'Article Edit Title'
        fill_in 'article_draft[content]', with: 'Article Edit content'
        fill_in 'article_draft[tag_list]', with: 'article'
        attach_file 'article_draft[image]', 'spec/fixtures/earth.png', visible: false
        attach_file 'article_draft[content][]', 'spec/fixtures/map.png', visible: false
        expect(page).to have_selector('#file-size-text', text: '残りファイルサイズ 9.51MB / 10MB')
        click_button '送信する'
      end

      it '記事の更新に成功すること' do
        expect(page).to have_selector('.alert-success')
      end

      it '投稿記事一覧に編集した記事のタイトルがあること' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it '記事のタイトルが変わっていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_content('Article Edit content')
      end

      it '編集で追加したヘッダー画像があること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it '編集で追加した記事の画像が表示されていること' do
        expect(page).to have_link('Article Edit Title', exact: true, visible: true)
        click_link 'Article Edit Title'

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'プロフィールページの下書き一覧に編集した記事に紐づく下書きがないこと' do
        expect(page).to have_content('Article Edit Title')
        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'delete draft' do
      let(:article_draft) { FactoryBot.create(:article_draft, user: user) }

      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it '削除した下書きがプロフィールページの下書き一覧にないこと' do
        expect(page).to have_link('下書きを削除', visible: true)
        page.accept_confirm do
          click_link '下書きを削除'
        end

        expect(page).to_not have_content(article_draft.title, exact: true)
      end

      it '確認ダイアログでキャンセルを選択すると記事が削除されないこと' do
        expect(page).to have_link('下書きを削除', visible: true)
        page.dismiss_confirm do
          click_link '下書きを削除'
        end

        expect(page).to have_current_path(preview_user_article_draft_path(user, article_draft))
      end
    end

    context 'delete posted article' do
      let!(:article) { FactoryBot.create(:article, user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit article_path(article)

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it '削除した記事がプロフィールページの記事一覧にないこと' do
        expect(page).to have_link('記事を削除', visible: true)
        page.accept_confirm do
          click_link '記事を削除'
        end

        expect(page).to_not have_content(article.title, exact: true)
      end

      it '確認ダイアログでキャンセルを選択すると記事が削除されないこと' do
        expect(page).to have_link('記事を削除', visible: true)
        page.dismiss_confirm do
          click_link '記事を削除'
        end

        expect(page).to have_current_path(article_path(article))
      end
    end
  end
end
