class Experiment::JsonDatum < ApplicationRecord
    self.table_name = "experiment_json_data"

    belongs_to :experiment
    belongs_to :part, class_name: 'Experiment::Part'
end