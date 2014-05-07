require_relative '../../../lib/email/email'

class StageCraftWebApp

  # Data about user
  get '/api/me' do
    api_require_auth
    api_ok @user.to_hash
  end

  # Signup
  post '/api/session/signup' do
    end_session!

    # throw off fuzzing attacks
    fake_cycles

    # require
    api_reject 'Please provide your email address.' if params['email'].blank?
    api_reject 'Please provide your password.' if params['password'].blank?
    api_reject 'Please provide your name.' if params['name'].blank?

    # homogenize
    params['email'].strip!
    params['email'].downcase!
    api_reject 'Hmm, your email address doesn\'t look right.' unless params['email'] =~ /.+@.+\..+/i

    params['name'].strip!

    # check for existing user
    existing_user = User.first(:email => params['email'])
    if existing_user
      if existing_user.password == params['password']
        # password matches, so lets just log them in
        set_session existing_user
        api_ok existing_user.to_hash
      else
        api_ok "Thanks for signing up! We sent you a validation email, so check your email inbox for a message from #{$settings.customer_service_email}"
      end
    end

    user = User.new({
      email: params['email'],
      name: params['name'],
    })

    # special stuff for password
    begin
      user.password = params['password']
      user.save
    rescue PasswordError => boom
      api_reject boom
    end

    meta = send_confirmation_email(user)
    api_ok(meta, "Thanks for signing up! We sent you a confirmation email to #{meta[:to]}. Check your email inbox for a message from #{meta[:from]}")
  end

  # Login
  post '/api/session/login' do
    end_session!

    # throw off fuzzing attacks
    fake_cycles

    api_reject 'Please provide your email address.' if params['username'].blank?
    api_reject 'Please provide your password.' if params['password'].blank?

    params['username'].strip!
    params['username'].downcase!
    params['password'].strip!

    # try email address
    user = User.first(:email => params['username'])
    api_require_auth 'The email address and password combination you entered is incorrect. Please try again.' unless user

    # try password
    api_require_auth 'The email address and password combination you entered is incorrect. Please try again.' unless user.password == params['password']

    # login!
    set_session user
    api_ok user.to_hash
  end

  post '/api/password/forgot' do
    api_reject 'Please provide your email address.' if params['username'].blank?

    params['username'].strip!
    params['username'].downcase!

    # throw off fuzzing attacks
    fake_cycles

    # first try email address
    user = User.first(:email => params['username'])
    api_reject 'Please provide your email address.' unless user

    # send reset email
    Email::Sender.send(:password_forgot, {
      :to => user.email,
      :email_token => user.smart_token.to_s,
      :name => user.login_name,
      :subject => 'Password Reset',
      :now => true
    })

    meta = { :to => user.email, :from => $settings.customer_service_email }
    api_ok(meta, "We sent you a confirmation email to #{meta[:to]}. Check your email inbox for a message from #{meta[:from]}")
  end

  post '/api/password/change' do
    api_require_auth
    api_reject 'Please provide a password.' if params['password'].blank?
    params['password'].strip!

    begin
      @user.password = params['password']
      @user.save
    rescue PasswordError => boom
      api_reject(boom)
    end

    flash[:success] = 'You have successfully changed your password. Try logging in.'
    api_ok(@user.to_hash, flash[:success])
  end

  # Send a confirmation email to the currently logged in user.
  post '/api/validation/email/send' do
    api_require_auth

    # send reset email
    meta = send_confirmation_email(@user)
    api_ok(meta, "We sent you a confirmation email to #{meta[:to]}. Check your email inbox for a message from #{meta[:from]}")
  end

  private

  # throw off fuzzing attacks
  def fake_cycles
    return if test?
    sleep(rand(0.25..0.75))
  end

  # Send a confirmation email
  def send_confirmation_email(user, last_sent_at = nil)
    # send one email every 2 minutes
    # TODO: upgrade timestamp to Redis
    last_sent_at = session[:last_validation_email_at] if last_sent_at.nil? and session and session[:last_validation_email_at]
    meta = { :to => user.email, :from => $settings.customer_service_email, :last_sent_at => last_sent_at }
    return meta if test?
    return meta if last_sent_at and Time.at(last_sent_at) >= 2.minutes.ago

    Email::Sender.send(:validation, {
      :to => user.email,
      :email_token => user.smart_token.to_s,
      :name => user.login_name,
      :subject => 'Confirmation Email',
      :now => true
    })

    # update timestamp
    meta[:last_sent_at] = Time.new.to_i
    session[:last_validation_email_at] = meta[:last_sent_at]

    meta
  end

  # verify the params['smart_token'] and return the user
  def start_session_with_smart_token
    require_relative '../../../lib/util/smart_token'
    smart_token = SmartToken.from_str(params['smart_token'])
    user = smart_token ? User.first(:guid => smart_token.guid) : nil

    if user and user.is_smart_token_valid? smart_token
      return user
    else
      return nil
    end
  end
end
