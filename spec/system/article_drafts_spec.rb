require 'rails_helper'

RSpec.describe 'ArticleDrafts', type: :system, js: true do

  describe '#preview' do
    let!(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }
    let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

    context 'when the author views the draft preview' do
      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)
      end

      it 'displays the kebab menu for draft actions' do 
        expect(page).to have_css('.dli-more-v')
      end

      it 'displays the link to edit the draft' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('下書きを編集')
      end

      it 'displays the link to delete the draft' do
        expect(page).to have_link('option', visible: true)
        click_link 'option'

        expect(page).to have_content('下書きを削除')
      end
    end

    context 'when another user views the draft preview' do
      before do
        sign_in other_user
        visit preview_user_article_draft_path(user, article_draft)
      end

      it 'displays the 404 error page' do
        expect(page).to have_content "ページが見つかりませんでした"
      end
    end
  end

  describe '#new' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'when the author accesses the page' do
      before do
        sign_in user
        visit new_user_article_draft_path(user)
      end

      it 'successfully accesses the page' do
        expect(current_path).to eq new_user_article_draft_path(user)
      end
    end

    context 'when another user accesses the page' do
      before do
        sign_in other_user
        visit new_user_article_draft_path(user)
      end

      it 'redirects to the root path' do
        expect(current_path).to eq root_path
      end
    end
  end

  describe '#autosave_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'when autosaving from the new draft path' do
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

      it 'displays the title of the autosaved draft in the draft list' do
        expect(page).to have_content('Article Autosave Title')
      end

      it 'retains the content of the autosaved draft' do
        find('.article-link').click

        expect(page).to have_content('Article Autosave Title')
        expect(page).to have_content('autosavearticle')
        expect(page).to have_selector("img[src$='earth.png']")
        expect(page).to have_selector("img[alt='map.png']")
      end
    end

    context 'when autosaving from the edit draft path' do
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

      it 'displays the title of the autosaved draft in the draft list' do
        expect(page).to have_content('Article Autosave Title')
      end

      it 'retains the content of the autosaved draft' do
        first('.article-link').click

        expect(page).to have_content('Article Autosave Title')
        expect(page).to have_content('autosavearticle')
        expect(page).to have_selector("img[src$='earth.png']")
        expect(page).to have_selector("img[alt='map.png']")
      end
    end
  end

  describe '#save_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'when saving as a draft' do
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

      it 'successfully saves the draft' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'displays the saved header image in the draft list on the profile page' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'displays the title of the saved draft in the draft list on the profile page' do
        expect(page).to have_content('Article Title')
      end

      it 'displays the attached image of the saved draft' do
        find('.article-link').click

        expect(page).to have_selector("img[alt='map.png']")
      end
    end
  end

  describe '#commit' do
    let(:user) { FactoryBot.create(:user) }

    context 'when submitting as a published article' do
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

      it 'successfully posts the article' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'displays the saved header image in the published article list on the profile page' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'displays the title of the published article in the published article list on the profile page' do
        expect(page).to have_content('Article Title')
      end

      it 'displays the attached image of the published article' do
        find('.article-link').click

        expect(page).to have_selector("img[alt='map.png']")
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Title')
      end
    end

    context 'when submitting as a private article' do
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

      it 'successfully posts the private article' do
        expect(page).to have_selector('div.alert-success')
      end

      it 'displays the saved header image in the private article list on the profile page' do
        expect(page).to have_selector("img[src$='earth.png']")
      end

      it 'displays the title of the private article in the private article list on the profile page' do
        expect(page).to have_content('Article Title')
      end

      it 'displays the attached image of the private article' do
        find('.article-link').click

        expect(page).to have_selector("img[alt='map.png']")
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Title')
      end
    end
  end

  describe '#edit' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'when the author accesses the edit page from an article page' do
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

      it 'successfully accesses the edit page' do
        expect(current_path).to eq edit_user_article_draft_path(user, article_draft)
      end
    end

    context 'when the author accesses the edit page from a draft preview page' do
      let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)

        expect(page).to have_link('option', visible: true)
        click_link 'option', match: :first, exact: true

        expect(page).to have_link('下書きを編集', visible: true)
        click_link '下書きを編集'
      end

      it 'successfully accesses the edit page' do
        expect(current_path).to eq edit_user_article_draft_path(user, article_draft)
      end
    end

    context 'when another user accesses the edit page' do
      let!(:article_draft) { FactoryBot.create(:article_draft, user: user)}

      before do
        sign_in other_user
        visit edit_user_article_draft_path(user, article_draft)
      end

      it 'displays the 404 error page' do
        expect(page).to have_content "ページが見つかりませんでした"
      end
    end
  end

  describe '#update_draft' do
    let(:user) { FactoryBot.create(:user) }

    context 'when editing a draft associated with a posted article' do
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

      it 'successfully updates the draft' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the draft list' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it 'changes the content of the draft' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'does not change the title of the original posted article' do
        find('.tab-type .tab', text: '投稿記事').click

        expect(page).to_not have_content('Article Edit Title')
      end

      it 'does not change the content of the original posted article' do
        find('.tab-type .tab', text: '投稿記事').click
        find('.article-link').click

        expect(page).to_not have_content('Article Edit content')
      end
    end

    context 'when editing a normal draft' do
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

      it 'successfully updates the draft' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the draft list' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it 'changes the content of the draft' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end
    end
  end

  describe '#update' do
    let!(:user) { FactoryBot.create(:user) }

    context'when publishing a draft as a public article' do
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

      it 'successfully publishes the article' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the published article list' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it 'changes the content of the article' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'when updating a posted public article' do
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

      it 'successfully updates the article' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the published article list' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it 'changes the content of the article' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'when updating a public article as a private article' do
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

      it 'successfully updates the article' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the private article list' do
        expect(page).to have_content('Article Edit Title')
      end

      it 'changes the content of the article' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Edit Title')

        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end

    context 'when updating a private article as a public article' do
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

      it 'successfully updates the article' do
        expect(page).to have_selector('.alert-success')
      end

      it 'displays the updated title in the published article list' do
        expect(page).to have_content('Article Edit Title')
      end
  
      it 'changes the content of the article' do
        find('.article-link').click

        expect(page).to have_content('Article Edit content')
      end

      it 'displays the added header image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='earth.png']"
      end

      it 'displays the added attached image' do
        find('.article-link').click

        expect(page).to have_selector "img[src$='map.png']"
      end

      it 'does not keep the article in the draft list on the profile page' do
        expect(page).to have_content('Article Edit Title')
        visit drafts_user_path(user)
        expect(page).to_not have_content('Article Edit Title')
      end
    end
  end

  describe '#destroy' do
    let(:user) { FactoryBot.create(:user) }
    let(:other_user) { FactoryBot.create(:other_user) }

    context 'when deleting a draft' do
      let(:article_draft) { FactoryBot.create(:article_draft, user: user) }

      before do
        sign_in user
        visit preview_user_article_draft_path(user, article_draft)

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it 'removes the deleted draft from the draft list on the profile page' do
        expect(page).to have_link('下書きを削除', visible: true)
        page.accept_confirm do
          click_link '下書きを削除'
        end

        expect(page).to_not have_content(article_draft.title, exact: true)
      end

      it 'does not delete the draft when the confirmation dialog is canceled' do
        expect(page).to have_link('下書きを削除', visible: true)
        page.dismiss_confirm do
          click_link '下書きを削除'
        end

        expect(page).to have_current_path(preview_user_article_draft_path(user, article_draft))
      end
    end

    context 'when deleting a posted article' do
      let!(:article) { FactoryBot.create(:article, user: user) }
      let!(:article_draft) { FactoryBot.create(:article_draft, article: article, user: user) }

      before do
        sign_in user
        visit article_path(article)

        expect(page).to have_link('option', visible: true)
        click_link 'option'
      end

      it 'removes the deleted article from the article list on the profile page' do
        expect(page).to have_link('記事を削除', visible: true)
        page.accept_confirm do
          click_link '記事を削除'
        end

        expect(page).to_not have_content(article.title, exact: true)
      end

      it 'does not delete the article when the confirmation dialog is canceled' do
        expect(page).to have_link('記事を削除', visible: true)
        page.dismiss_confirm do
          click_link '記事を削除'
        end

        expect(page).to have_current_path(article_path(article))
      end
    end
  end
end
