require 'data_mapper'
require 'securerandom'
require 'bcrypt'
require 'oj'
require_relative 'errors'
require_relative '../util/guid'

# An authenticated user
class User
  include DataMapper::Resource
  before :create, :before_create

  property :id, Serial
  property :guid, String, :unique_index => true
  property :email, String, :unique_index => true
  property :name, String

  # timestamps
  property :created_at, DateTime
  property :updated_at, DateTime
  property :visit_at, DateTime
  property :email_validated_at, DateTime

  # authentication
  property :pass_hash, String

  def login_name
    @name || @email || "User_#{@guid}"
  end

  # the user's Password object
  def password
    return nil unless @pass_hash
    @password ||= BCrypt::Password.new(@pass_hash)
    @password
  end

  # set the password using bcrypt
  def password=(new_password)
    new_password.strip! unless new_password.blank?
    raise PasswordError.new 'Please set a password.' if new_password.blank?
    raise PasswordError.new 'Please set a password greater than six characters.' if new_password.length < 6
    raise PasswordError.new 'Please use a better password.' if new_password.downcase.include?('password')

    @password = BCrypt::Password.create(new_password, { :cost => 13 })
    @smart_token = nil # clear this because it is generated from password hash
    self.pass_hash = @password.to_s
  end

  # set the password to a random value
  def password_randomize!
    random_password = Array.new(16).map { (65 + rand(58)).chr }.join
    self.password = random_password
  end

  # create a credentials hash good for 72-hours
  def smart_token
    # already generated
    return @smart_token if @smart_token

    # make sure there's a password
    if @pass_hash.nil?
      password_randomize!
      save
    end

    require_relative '../util/smart_token'
    @smart_token = SmartToken.new(@guid).sign!(smart_token_secret)
  end

  # validate a SmartToken string
  def is_smart_token_valid?(smart_token)
    smart_token = smart_token.is_a?(SmartToken) ? smart_token : SmartToken.from_str(smart_token)
    smart_token.is_valid? smart_token_secret
  end

  # is the user's email validated?
  def is_email_validated?
    self.email_validated_at.present?
  end

  # set the user's email as validated
  def validate_email!
    self.email_validated_at = Time.new
    self.save
  end

  def is_admin?
    return false unless email
    $settings.admin_emails.include?(email)
  end

  # Same as update_visit_at!, but only once every 15-minutes
  def update_visit_at
    time = Time.now
    if visit_at.nil? or (time - visit_at) >= 15.minutes
      update_visit_at!(time)
    end
  end

  # Will save the time session was granted
  def update_visit_at!(time = nil)
    self.visit_at = time || Time.now
    self.save
  end

  def to_hash
    data = {}
    [:guid, :email, :name, :created_at, :updated_at, :visit_at, :email_validated_at, :phone_validated_at].each do |field|
      data[field] = self[field]
    end
    data
  end

  def to_json
    Oj.dump(to_hash)
  end

  private

  def smart_token_secret
    return "#{@guid}-#{$settings.http_session_secret}" if @pass_hash.nil?
    return "#{@pass_hash}-#{$settings.http_session_secret}"
  end

  def before_create
    self.guid = Guid::generate(5, "#{smart_token_secret}-#{email}")
  end

end