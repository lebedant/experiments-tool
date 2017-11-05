class CreateTestVariables < ActiveRecord::Migration[5.1]
  def change
    create_table :test_variables do |t|
      t.integer :data_type
      t.string :name
      t.boolean :log_transform
      t.belongs_to :test_part, index: true

      t.timestamps
    end
  end
end
