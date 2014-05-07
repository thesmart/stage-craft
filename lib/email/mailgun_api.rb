
module Email
  class MailGunApi

    def initialize(api_key, custom_domain)
      require 'faraday'
      require 'faraday_middleware'
      require 'oj'

      @api = Faraday.new(:url => 'https://api.mailgun.net') do |faraday|
        faraday.request :url_encoded
        faraday.adapter :net_http
      end
      @api.basic_auth('api', api_key)
      @api.headers['User-Agent'] = 'stage-craft/Email::MailGunApi (Faraday/0.8.8)'
      @custom_domain = custom_domain
    end

    # send an email
    def send(options)
      [:from, :to, :subject, :html].each do |field|
        raise ArgumentError.new "Missing required option: #{field}" unless options[field].present?
      end

      resp = @api.post "/v2/#{@custom_domain}/messages", options
      if resp.status > 299
        raise Errors::EmailSendError.new('MailGunApi::send', resp)
      end
      Oj.load(resp.body)
    end
  end
end