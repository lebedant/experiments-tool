class AddRepetitionCountToVariable < ActiveRecord::Migration[5.1]
  def change
    add_column :test_variables, :repetition_count, :integer, default: 1
  end
end
