class TestDatum < ApplicationRecord
    belongs_to :test_variable
    belongs_to :target, polymorphic: true
end
