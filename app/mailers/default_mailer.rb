class DefaultMailer < ApplicationMailer
  def admin_email_info(subject, message)
    @subject = subject
    @message = message
    mail(to: "admin@example.com", subject: 'Info: #{message}')
  end
  def admin_email_warning(subject, message)
    @subject = subject
    @message = message
    mail(to: "admin@example.com", subject: 'Warning: #{message}')
  end
  def admin_email_error(subject, message)
    @subject = subject
    @message = message
    mail(to: "admin@example.com", subject: 'Error: #{message}')
  end

  def user_email_welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to myproject')
  end
  def user_email_notification(user, subject, message)
    @user = user
    @subject = subject
    @message = message
    mail(to: @user.email, subject: subject)
  end
end
