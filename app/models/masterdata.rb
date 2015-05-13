class Masterdata < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "#{Rails.env}_masterdata".to_sym
end
