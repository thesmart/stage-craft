module Email
  class EmailAssist
    SITES_MAP = {
      'hotmail.com' => 'www.hotmail.com',
      'hotmail.co.uk' => 'www.hotmail.co.uk',
      'yahoo.com' => 'mail.yahoo.com',
      'gmail.com' => 'www.gmail.com/#all',
      'yahoo.co.uk' => 'mail.yahoo.co.uk',
      'aol.com' => 'webmail.aol.com',
      'msn.com' => 'www.hotmail.com',
      'btinternet.com' => 'signin1.bt.com/login/emailloginform',
      'hotmail.fr' => 'mail.live.com',
      'live.co.uk' => 'mail.live.com',
      'googlemail.com' => 'accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/',
      'live.com' => 'mail.live.com',
      'yahoo.gr' => 'mail.yahoo.gr',
      'yahoo.ca' => 'mail.yahoo.ca',
      'yahoo.fr' => 'mail.yahoo.fr',
      'yahoo.com.au' => 'mail.yahoo.com.au',
      'sky.com' => 'mysky.sky.com/portal/servlet/ssorouter?tc=portlets-tools-page&ts=ToolsRedirectServlet&event=email',
      'yahoo.co.in' => 'mail.yahoo.co.in',
      'aim.com' => 'mail.aim.com',
      'fsmail.net' => 'fsmail01.orange.co.uk/webmail/en_GB/inbox.html',
      'live.ca' => 'mail.live.com',
      'hotmail.it' => 'www.hotmail.it',
      'yahoo.ie' => 'mail.yahoo.ie',
      'yahoo.com.sg' => 'mail.yahoo.com.sg',
      'comcast.net' => 'https://login.comcast.net/login?s=portal&continue=http%3A%2F%2Fxfinity.comcast.net%2Fwebmail%2Fbin%2F',
      'windowslive.com' => 'mail.live.com',
      'live.com.au' => 'mail.live.com',
      'rogers.com' => 'mail.rogers.com',
      'walla.com' => 'mail.walla.co.il',
      'mac.com' => 'www.mac.com',
      'free.fr' => 'imp.free.fr',
      'sbcglobal.net' => 'webmail.att.net',
      'optusnet.com.au' => 'webmail.optuszoo.com.au',
      'yahoo.com.hk' => 'mail.yahoo.com.hk',
      'yahoo.it' => 'mail.yahoo.it',
      'live.ie' => 'mail.live.com',
      'yahoo.de' => 'mail.yahoo.de',
      'yahoo.co.nz' => 'mail.yahoo.co.nz',
      'vodamail.co.za' => 'myvodacom.secure.vodacom.co.za/personal/main/login',
      'yahoo.es' => 'mail.yahoo.es',
      'hotmail.de' => 'mail.live.com',
      'live.fr' => 'mail.live.com',
      'yahoo.se' => 'mail.yahoo.se',
      'aol.co.uk' => 'webmail.aol.co.uk',
      'verizon.net' => 'webmail.verizon.net/signin/',
      'orange.fr' => 'r.orange.fr/r/Owebmail_inbox_v2',
      'yahoo.dk' => 'mail.yahoo.dk',
      'yahoo.no' => 'mail.yahoo.no',
      'live.co.za' => 'mail.live.com',
      'lycos.com' => 'mail.lycos.com',
      'yahoo.com.mx' => 'mail.yahoo.com.mx',
      'live.se' => 'mail.live.com',
      'att.net' => 'webmail.att.net',
      'earthlink.net' => 'webmail.earthlink.net',
      'yahoo.com.ar' => 'mail.yahoo.com.ar',
      'live.dk' => 'mail.live.com',
      'live.no' => 'mail.live.com',
      'yahoo.com.br' => 'yahoo.com.br',
      'live.nl' => 'mail.live.com',
      'home.se' => 'www.home.se',
      'yahoo.co.id' => 'mail.yahoo.co.id',
      'hotmail.es' => 'mail.live.com'
    }

    # lookup Internet Service Provider sinfo about an email address
    def self.lookup(email)
      email = email.downcase
      email_parts = email.split('@')
      domain = email_parts[1].downcase

      info = {
        :url => nil,
        :name => domain.split('.')[0].capitalize
      }
      info[:url] = "http://#{SITES_MAP[domain]}" if SITES_MAP[domain]
      info
    end
  end
end