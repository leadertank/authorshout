class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Welcome to AuthorShout"
    )
  end

  def admin_created_member_email(user, temporary_password)
    @user = user
    @temporary_password = temporary_password

    mail(
      to: @user.email,
      subject: "Your AuthorShout account is ready"
    )
  end
end
