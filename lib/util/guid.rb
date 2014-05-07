# Generate short unique ids
module Guid

  # Generate a guid based on a seed string (like user id, or something else that rarely changes)
  def self.generate(size = 4, seed = nil)
    seed = seed.to_s if seed

    guid_a = []
    rando = Digest::SHA256.base64digest(seed).downcase if seed.is_a? String and seed.length > 0
    rando = SecureRandom.base64(size * 5).downcase unless seed
    rando.each_char do |c|
      guid_a << c if c =~ /^[a-z0-9]$/
      guid_a.pop if guid_a.join =~ /^[0-9]+$/
      if guid_a.length >= size
        break
      end
    end

    guid_a.slice(0, size).join
  end

  # Generate a guid and validate it's uniqueness by calling &block(guid) that returns true if unique
  def self.generate_unique(size = 4, seed = nil, tries = 10, &block)
    tries.times do
      guid = generate(size, seed)
      is_unique = block.call(guid)
      return guid if is_unique
    end
    raise RuntimeError.new "unable to create unique guid in #{tries} tries"
  end

end