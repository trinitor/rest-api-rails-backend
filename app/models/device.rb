class Device < Masterdata
  belongs_to :user

   validates :push_token,
             :presence => { message: "push_token must be set" },
             :uniqueness => { message: "push_token must be unique", case_sensitive: false }
   validates :os,
             inclusion: { in: %w(iOS Android), message: "%{value} is not a valid OS" }

  def send_push(message)
    if self.os == "iOS"
      n = Rpush::Apns::Notification.new
      n.app = Rpush::Apns::App.find_by_name("myproject")
      n.device_token = self.push_token # 64-character hex string
      n.alert = message
      n.data = { foo: :bar }
      n.save!
    end
  end
end
