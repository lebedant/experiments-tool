class TestPart < ApplicationRecord
    belongs_to :test
    has_many :test_variables
    has_secure_token :access_token

    accepts_nested_attributes_for :test_variables, reject_if: :all_blank, allow_destroy: true

    DESIGN_TYPES = {
        within_subject: 0,
        between_subject: 1
    }

    validates_presence_of :name, :test_variables
end
