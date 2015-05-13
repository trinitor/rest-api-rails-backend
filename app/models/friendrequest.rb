class Friendrequest < Masterdata
  belongs_to :user
  belongs_to :friend, :class_name => 'User'
end
