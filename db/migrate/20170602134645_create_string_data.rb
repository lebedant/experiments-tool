class CreateStringData < ActiveRecord::Migration[5.1]
  def change
    create_table :string_data do |t|
      t.string :value
    end
  end
end
