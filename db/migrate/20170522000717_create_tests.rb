class CreateTests < ActiveRecord::Migration[5.1]
  def change
    create_table :tests do |t|
      t.string :name
      t.string :description
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
