class CreateTestParts < ActiveRecord::Migration[5.1]
  def change
    create_table :test_parts do |t|
      t.string :access_token
      t.string :name
      t.string :description
      t.integer :design_type
      t.belongs_to :test, index: true

      t.timestamps
    end
    add_index :test_parts, :access_token, unique: true
  end
end
