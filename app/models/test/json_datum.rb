class Test::JsonDatum < ApplicationRecord
    self.table_name = "experiment_json_data"

    belongs_to :test
    belongs_to :part, class_name: 'Test::Part'
end