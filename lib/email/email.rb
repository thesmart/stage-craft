require 'erubis'
require_relative 'errors'

module Email

  class View

    def initialize(options)
      options.each do |key, val|
        unless instance_variable_get(:"@#{key}")
          instance_variable_set(:"@#{key}", val)
          self.class.send(:attr_accessor, key)
        end
      end
    end

    private

    # helpers
    def root_url
      $settings.url
    end

    def url_encode(txt)
      URI::encode(txt.to_s)
    end
  end

  class Sender
    VIEWS_FOLDER = File.absolute_path("#{__dir__}/views")

    # initialize views
    @@views = {}
    def self.init
      Dir["#{VIEWS_FOLDER}/*.erb"].each do |file|
        erb = File.read(file)
        name = file.split('/')[-1].gsub('.erb', '')
        @@views[name.to_sym] = ::Erubis::Eruby.new(erb)
      end
    end
    self.init

    # render email view
    def self.render(view, options = {})
      options[:view] = view.to_sym
      options[:layout] = (options[:layout] || :layout).to_sym
      raise Errors::EmailViewError.new("Email view not found: '#{VIEWS_FOLDER}/#{options[:view]}.erb'") if @@views[options[:view]].nil?
      raise Errors::EmailViewError.new("Email layout not found: '#{VIEWS_FOLDER}/#{options[:layout]}.erb'") if @@views[options[:layout]].nil?

      view = View.new(options)
      @@views[options[:layout]].evaluate(view) { @@views[options[:view]].evaluate(view) }
    end

    # send an email
    def self.send(view, options = {})
      html = self.render(view, options)
      meta = {
        :from => $settings.customer_service_email,
        :to => options[:to],
        :subject => options[:subject],
        :html => html
      }

      if options[:now]
        require_relative 'mailgun_api'
        mailgun = MailGunApi.new($settings.mailgun_api_key, $settings.mailgun_custom_domain)
        mailgun.send(meta)
      else
        meta[:type] = :send_email_job
        Q.worker.put Oj.dump(meta)
      end
    end
  end

end