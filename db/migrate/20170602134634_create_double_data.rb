class CreateDoubleData < ActiveRecord::Migration[5.1]
  def change
    create_table :double_data do |t|
      t.decimal :value
    end
  end
end
