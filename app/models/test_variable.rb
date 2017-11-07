class TestVariable < ApplicationRecord
    belongs_to :test_part
    has_many :test_data

    DATA_TYPES = {
        string: 0,
        long: 1,
        double: 2
    }

    validates_presence_of :name, :data_type
end
