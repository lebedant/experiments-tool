class AddCalculationMethodToVariable < ActiveRecord::Migration[5.1]
  def change
    remove_column :experiment_variables, :log_transform, :boolean
    add_column :experiment_variables, :calculation_method, :integer
  end
end
