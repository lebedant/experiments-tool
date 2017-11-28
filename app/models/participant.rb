class Participant < ApplicationRecord
  has_many :experiment_data, dependent: :destroy
  has_many :experiment_json_data, dependent: :destroy

end
