class SessionsController < ApplicationController
  def create
    unless request.env['omniauth.auth'][:uid]
      flash[:danger] = "連携に失敗しました"
      redirect_to root_url
    end

    user_data = request.env['omniauth.auth']
    user = User.find_by(provider: user_data[:provider], uid: user_data[:uid])
    if user
      user.update(user_name: user_data[:info][:name], image_url: user_data[:info][:image])
      log_in user
      flash[:success] = "ログインしました"
    else
      new_user = User.new(
        provider: user_data[:provider],
        uid: user_data[:uid],
        user_name: user_data[:info][:name],
        image_url: user_data[:info][:image]
      )

      if new_user.save
        log_in new_user
        flash[:success] = "ユーザー登録成功"
      else
        flash[:danger] = "ユーザー登録失敗"
      end
    end
    redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    flash[:success] = "ログアウトしました"
    redirect_to root_url
  end
end
