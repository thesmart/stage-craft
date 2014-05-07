require 'digest/sha2'

class SmartToken

  attr_accessor :guid, :signature, :time

  # @param [String] guid Unique id
  # @param [Integer] time Unix time since epoch
  def initialize(guid, time = nil)
    @guid = guid
    @time = time ? time.to_i : Time.new.to_i
    @signature = nil
  end

  def to_s
    [@guid, @signature || 'UNDEFINED', @time].join('-')
  end

  # sign this token using a secret
  def sign!(secret)
    @signature = self.class.sign(@guid, secret, @time)
    self
  end

  # is this token signed?
  def is_signed?
    @signature.present?
  end

  # SmartToken is stale? (1-hour)
  def is_stale?
    @time <= 1.hour.ago.to_i
  end

  # SmartToken is expired? (72-hours)
  def is_expired?
     self.class.is_expired?(@time)
  end

  # validate the token against a known secret
  def is_valid?(secret)
    return false if is_expired?
    return false unless is_signed?
    signature = self.class.sign(@guid, secret, @time)
    return signature == @signature
  end

  # build a SmartToken from String
  # @return [SmartToken]
  def self.from_str(str)
    parts = str.to_s.split('-')
    return nil unless parts.length == 3
    smart_token = SmartToken.new(parts[0], parts[2])
    smart_token.signature = parts[1]
    smart_token
  end

  private

  # sign a set using sha2
  def self.sign(guid, secret, time)
    sha2 = Digest::SHA2.new
    sha2.update guid.to_s
    sha2.update secret.to_s
    sha2.update time.to_s
    sha2.to_s
  end

  # is a timeout expired?
  def self.is_expired?(time)
    return time.to_i <= 72.hours.ago.to_i
  end
end
