class Participant < ApplicationRecord
  validates_presence_of :test_id
  belongs_to :test
  has_many :test_data, dependent: :destroy

end
