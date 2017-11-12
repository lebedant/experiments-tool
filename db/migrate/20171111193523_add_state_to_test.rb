class AddStateToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :state, :string
  end
end
