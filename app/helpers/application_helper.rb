module ApplicationHelper
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
