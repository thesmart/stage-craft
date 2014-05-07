class String
  def normalize_phone
    require 'phony'
    phone = Phony.normalize(self, :format => :international, :spaces => '')
    phone.prepend('1') if phone[0] != '1'
    phone
  end

  # is the string similar to number?
  def is_integer?
    self =~ /\A-?(?:0|[1-9][0-9]*)\z/
  end

  # is the string similar to a url?
  def is_url?
    self =~ /^#{URI::regexp}$/
  end

  # is the string similar to a Range?
  def is_range?
    self =~ /\A(([\d]+)|(['"][\w]{1}['"]))\.\.\.?(([\d]+)|(['"][\w]{1}['"]))\z/i
  end

  # is the string a well-formed EU or US currency figure?
  def is_currency?
    self =~ /\A[+-]?[0-9]{1,3}(?:[0-9]*(?:[.,][0-9]{2})?|(?:,[0-9]{3})*(?:\.[0-9]{2})?|(?:\.[0-9]{3})*(?:,[0-9]{2})?)\z/i
  end

  # convert a query string into a hash
  def from_query_to_hash
    hash = CGI::parse(self)
    hash.each do |key, val|
      hash[key] = val[0] if val and val.length == 1
    end
    hash
  end
end