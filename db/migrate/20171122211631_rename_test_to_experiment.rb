class RenameTestToExperiment < ActiveRecord::Migration[5.1]
  def change
    rename_table :tests, :experiments
    rename_table :test_parts, :experiment_parts
    rename_table :test_variables, :experiment_variables
    rename_table :test_data, :experiment_data

    rename_column :experiment_parts, :test_id, :experiment_id
    rename_column :experiment_json_data, :test_id, :experiment_id
  end
end
