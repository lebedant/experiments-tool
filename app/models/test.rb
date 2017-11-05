class Test < ApplicationRecord
    validates_presence_of :name
    has_many :test_parts, :dependent => :destroy
    belongs_to :user

    accepts_nested_attributes_for :test_parts, reject_if: :all_blank, allow_destroy: true
end
