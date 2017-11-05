class CreateLongData < ActiveRecord::Migration[5.1]
  def change
    create_table :long_data do |t|
      t.integer :value
    end
  end
end
