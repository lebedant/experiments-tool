class CreateTestData < ActiveRecord::Migration[5.1]
  def change
    create_table :test_data do |t|
        t.integer :target_id
        t.string :target_type
        t.references :participant, foreign_key: true
        t.belongs_to :variable, index: true

        t.timestamps
    end
  end
end
