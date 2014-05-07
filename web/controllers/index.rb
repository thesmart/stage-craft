#noinspection RubyResolve
class StageCraftWebApp
  get '/' do
    if has_session?
      redirect '/hello'
    end

    erb :start
  end

  get '/hello' do
    erb :hello
  end

  get '/privacy' do
    erb :privacy
  end

  get '/terms' do
    erb :terms
  end

end