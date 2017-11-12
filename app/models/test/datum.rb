class Test::Datum < ApplicationRecord
    belongs_to :variable, class_name: 'Test::Variable'
    belongs_to :participant
    belongs_to :target, polymorphic: true

end
