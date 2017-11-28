class RemoveTestRef < ActiveRecord::Migration[5.1]
  def change
    remove_column :participants, :test_id
  end
end
