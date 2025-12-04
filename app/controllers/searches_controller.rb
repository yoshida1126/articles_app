class SearchesController < ApplicationController

  def search
    @search_word = params[:q].values.compact.first.to_s

    if /\A#.+/ =~ @search_word
      @search_word = @search_word.sub(/^#/, '')
      @search_word.gsub!(" ", "")
      @search_word.gsub!("　", "")
      return redirect_to tag_path(@search_word), status: :see_other
    else
      @target = params.dig(:q, :target) || 'article'

      @target == 'user' ? params[:q].delete(:created_at_filter) : set_date_params

      case @target
      when 'article'
        search = Article.published.ransack(params[:q])
        @search_articles = search.result(distinct: true).order(created_at: :desc)
      when 'list'
        search = FavoriteArticleList.ransack(params[:q])
        @search_lists = search.result(distinct: true).order(created_at: :desc)
      when 'user'
        search = User.ransack(params[:q])
        @search_users = search.result(distinct: true).order(created_at: :desc)
      end
    end
  end

  private

  def set_date_params
    date_filter = params.dig(:q, :created_at_filter).presence

    if date_filter.present?
      params[:q][:created_at_gteq] = case date_filter
      when "today"
        Time.zone.today.beginning_of_day
      when "yesterday"
        1.day.ago.beginning_of_day
      when "this_week"
        Time.zone.today.beginning_of_week(:monday)
      when "this_month"
        Time.zone.today.beginning_of_month
      when "this_year"
        Time.zone.today.beginning_of_year
      end

      params[:q][:created_at_lteq] = Time.zone.now.end_of_day
    end
  end
end
