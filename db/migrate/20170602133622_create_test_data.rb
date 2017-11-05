class CreateTestData < ActiveRecord::Migration[5.1]
  def change
    create_table :test_data do |t|
        t.integer :session_id
        t.integer :target_id
        t.string :target_type
        t.belongs_to :test_variable, index: true

        t.timestamps
    end
  end
end
