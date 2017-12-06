class Participant < ApplicationRecord
  has_many :data, class_name: 'Experiment::Datum', dependent: :destroy
  has_many :json_data, class_name: 'Experiment::JsonDatum', dependent: :destroy

end