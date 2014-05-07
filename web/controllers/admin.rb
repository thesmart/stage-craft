class StageCraftWebApp
  get '/admin' do
    require_admin
    # users
    users = User.all(:order => [ :id.desc ], :limit => 100)

    erb :'/admin/dashboard', {},
      :users => users
  end

  get '/admin/users' do
    require_admin
    users = User.all(:order => [ :visit_at.desc ], :limit => 300)
    erb :'/admin/users', {},
      :users => users
  end

  get '/admin/user/:user' do
    require_admin

    other = nil
      if /\A[0-9]+\z/ =~ params[:user]
      other = User.first(:id => params[:user])
    elsif /\A[0-9a-z]+\z/i =~ params[:user]
      other = User.first(:guid => params[:user])
    end

    if other.nil?
      not_found
    end

    erb :'/admin/user', {},
      :other => other
  end

  private

  def require_admin
    user = get_user
    redirect '/' unless has_session? and user.is_admin?
    @admin = user
  end
end