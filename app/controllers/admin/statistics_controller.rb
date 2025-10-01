class Admin::StatisticsController < ApplicationController
  def index
  end

  def users
  end

  def articles
    @range = params[:range] || 'week'

    @post_counts = case @range
    when 'day'
      Article
        .unscope(:order)
        .group("DATE(created_at)")
        .order(Arel.sql("DATE(created_at) ASC"))
        .count
    when 'week'
      Article
        .unscope(:order)
        .group("YEARWEEK(created_at, 1)")
        .order(Arel.sql("YEARWEEK(created_at, 1) ASC"))
        .count
    when 'month'
      Article
        .unscope(:order)
        .group("DATE_FORMAT(created_at, '%Y-%m')")
        .order(Arel.sql("DATE_FORMAT(created_at, '%Y-%m') ASC"))
        .count
    when 'year'
      Article
        .unscope(:order)
        .group("YEAR(created_at)")
        .order(Arel.sql("YEAR(created_at) ASC"))
        .count
    end
  end

  def comments
  end
end
