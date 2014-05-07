require_relative '../../lib/email/email'

class StageCraftWebApp
  get '/email/preview/:type' do
    not_found unless development?
    content_type 'text/html'
    Email::Sender.init # reset views
    Email::Sender.render(params[:type].to_sym, params)
  end

end