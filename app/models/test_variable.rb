class TestVariable < ApplicationRecord
    belongs_to :test_part

    DATA_TYPES = {
        string: 0,
        long: 1,
        double: 2
    }
end
