module ApplicationHelper

  def full_title(page_title = '')
    base_title = "Articles"
    if page_title.empty?
      base_title
    else
      "#{ page_title } | #{ base_title }"
    end
  end

  def bootstrap_alert(key, value)
    case key
    when 'alert'
      if value === 'You have to confirm your email address before continuing.'
        'warning'
      else
        'danger'
      end
    when 'notice'
      if value === 'Please check your email to active your account.'
        'info'
      else
        'success'
      end
    end
  end

  def show_header?
    return false if controller_name == 'article_drafts' && ['new', 'edit'].include?(action_name)
    return false if controller_name == 'article_drafts' && ['save_draft', 'commit', 'update_draft', 'update'].include?(action_name) && @draft&.errors&.any?
    true
  end
end
