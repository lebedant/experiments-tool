class AddPositiveValueToVariable < ActiveRecord::Migration[5.1]
  def change
    add_column :experiment_variables, :positive_value, :integer
  end
end
