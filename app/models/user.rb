class User < Masterdata
  has_secure_password

  before_create :generate_token

  has_many :devices

  has_many :friendships
  has_many :friends, through: :friendships

  has_many :friendrequests

  validates :name,
            :presence => { message: "name must be set" },
            :uniqueness => { message: "name must be unique", case_sensitive: false },
            :length => { :in => 3..20 }
  validates_length_of :password, :in => 6..30, :on => :create

  def generate_token
    loop do
      self.auth_token = SecureRandom.urlsafe_base64(nil, false)
      break self.auth_token unless self.class.exists?(auth_token: self.auth_token)
    end
  end

  def send_push(message)
    self.devices.each do |device|
      device.send_push(message)
    end
  end

  def send_email(subject, message)
    DefaultMailer.user_email_notification(self, subject, message).deliver_now
  end
end
