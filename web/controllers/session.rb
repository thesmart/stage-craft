class StageCraftWebApp
  get '/login' do
    if has_session?
      redirect '/'
    end

    @username = params[:username] || session[:username]
    erb :login
  end

  get '/signup' do
    if has_session?
      redirect '/'
    end

    @username = params[:username]
    erb :signup
  end

  get '/validate' do
    require_login
    if @user.is_email_validated?
      # already validated
      redirect '/'
    end

    send_confirmation_email(@user)

    require_relative '../../lib/email/email_assist'
    @isp_info = Email::EmailAssist.lookup(@user.email)

    erb :validate_instructions
  end

  get '/validate/:smart_token' do
    params['smart_token'].strip!
    if params['smart_token'].blank?
      flash[:warn] = 'Sorry, but your email validation code has expired. Try again.'
      redirect '/validate'
    end

    user_from_token = start_session_with_smart_token
    if user_from_token.nil?
      flash[:warn] = 'Sorry, but your email validation code has expired. Try again.'
      redirect '/validate'
    end

    set_session user_from_token
    @user.validate_email!

    flash[:success] = 'You have successfully confirmed your email address.'
    redirect '/'
  end

  get '/password/forgot' do
    if has_session?
      redirect '/'
    end

    erb :password_forgot
  end

  get '/password/change' do
    if has_session?
      redirect '/'
    end

    flash[:warn] = 'Sorry, but your request to change your password has expired. Try again.'
    redirect '/password/forgot'
  end

  get '/password/change/:smart_token' do
    if has_session?
      redirect '/'
    end

    params['smart_token'].strip!
    if params['smart_token'].blank?
      flash[:warn] = 'Sorry, but your request to change your password has expired. Try again.'
      redirect '/password/forgot'
    end

    # verify the token
    @user = start_session_with_smart_token

    if @user
      @user.validate_email!
      erb :password_change
    else
      flash[:warn] = 'Sorry, but your request to change your password has expired. Try again.'
      redirect '/password/forgot'
    end
  end

  get '/logout' do
    end_session!
    flash[:warn] = 'You have logged out.'
    redirect '/login'
  end

end