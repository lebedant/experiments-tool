class AddRepetitionCountToPart < ActiveRecord::Migration[5.1]
  def change
    add_column :experiment_parts, :repetition_count, :integer, default: 1
  end
end
