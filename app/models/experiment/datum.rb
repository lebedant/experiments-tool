class Experiment::Datum < ApplicationRecord
  belongs_to :variable, class_name: 'Experiment::Variable'
  belongs_to :participant
  belongs_to :target, polymorphic: true

  scope :active, -> { where(delete_reason: nil) }

end
