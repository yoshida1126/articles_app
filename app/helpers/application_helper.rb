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
end
