require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#full_title' do

    context 'when page_title is not provided' do
      it 'タイトルだけ返すこと' do
        result = helper.full_title
        expect(result).to eq 'Articles'
      end
    end

    context 'when page_title is provided' do
      it 'サイト名が付加されたタイトルを返すこと' do
        result = helper.full_title('TEST')
        expect(result).to eq 'TEST | Articles'
      end
    end
  end

  describe '#bootstrap_alert' do
    
    context 'when key is "alert"' do

      context 'when value is the confirmation message' do

        it 'warningを返すこと' do
          value = 'You have to confirm your email address before continuing.'
          result = helper.bootstrap_alert('alert', value)
          expect(result).to eq 'warning'
        end
      end

      context 'when value is any other message' do

        it 'dangerを返すこと' do
          result = helper.bootstrap_alert('alert', 'test')
          expect(result).to eq 'danger'
        end
      end
    end

    context 'when key is "notice"' do
      context 'when value is the activation message' do

        it 'infoを返すこと' do
          value = 'Please check your email to active your account.'
          result = helper.bootstrap_alert('notice', value)
          expect(result).to eq 'info'
        end
      end

      context 'when value is any other message' do

        it 'successを返すこと' do
          result = helper.bootstrap_alert('notice', 'test')
          expect(result).to eq 'success'
        end
      end
    end
  end

  describe '#show_header?' do
    before do
      allow(controller).to receive(:controller_name).and_return(controller_name)
      allow(controller).to receive(:action_name).and_return(action_name)
    end

    context 'when controller is "article_drafts"' do
      let(:controller_name) { 'article_drafts' }

      context 'when action is "new" or "edit"' do
        let(:action_name) { 'new' }

        it 'falseを返すこと' do
          expect(helper.show_header?).to be false
        end
      end

      context 'when action is "save_draft" and the draft has errors' do
        let(:action_name) { 'save_draft' }

        before do
          draft = double('draft')
          errors = double('errors', any?: true)
          allow(draft).to receive(:errors).and_return(errors)
          assign(:draft, draft)
        end

        it 'falseを返すこと' do
          expect(helper.show_header?).to be false
        end
      end

      context 'when action is "save_draft" but the draft has no errors' do
        let(:action_name) { 'save_draft' }

        before do
          draft = double('draft', errors: double('errors', any?: false))
          assign(:draft, draft)
        end

        it 'trueを返すこと' do
          expect(helper.show_header?).to be true
        end
      end
    end

    context 'when controller is other than "article_drafts"' do
      let(:controller_name) { 'articles' }
      let(:action_name) { 'index' }

      it 'trueを返すこと' do
        expect(helper.show_header?).to be true
      end
    end
  end
end