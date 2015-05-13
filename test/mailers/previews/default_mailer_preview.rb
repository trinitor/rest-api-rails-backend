# Preview all emails at http://localhost:3000/rails/mailers/default_mailer
class DefaultMailerPreview < ActionMailer::Preview
  def admin_email_info_preview
    DefaultMailer.admin_email_info("Info Mail Subject", "Info mail body")
  end
  def admin_email_warning_preview
    DefaultMailer.admin_email_info("Warning Mail subject", "warning mail body")
  end
  def admin_email_error_preview
    DefaultMailer.admin_email_info("Error Mail subject", "Error mail body")
  end

  def user_email_welcome_preview
    DefaultMailer.user_email_welcome(User.first)
  end
  def user_email_notification_preview
    DefaultMailer.user_email_notification(User.first, "My subject", "some information to include")
  end
end
