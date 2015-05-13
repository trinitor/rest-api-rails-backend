class Friendship < Masterdata
  belongs_to :user
  belongs_to :friend, :class_name => 'User'

  def self.create_friendship (user_id,friend_id,status)
    request1 = Friendship.new(user_id: user_id, friend_id: friend_id, status: "0")
    request2 = Friendship.new(user_id: friend_id, friend_id: user_id, status: "0")
    request3 = Friendrequest.where(user_id: friend_id, friend_id: user_id).first
    if status.between?(2,4)
      request1.status = status
      request2.status = status
    end
    Friendship.transaction do
      request1.save!
      request2.save!
      request3.destroy
    end
  end

  def self.delete_friendship (user_id,friend_id)
    request1 = Friendship.where("user_id = ? AND friend_id = ?", user_id, friend_id).first
    request2 = Friendship.where("user_id = ? AND friend_id = ?", friend_id, user_id).first
    Friendship.transaction do
      request1.destroy!
      request2.destroy!
    end
  end
end
