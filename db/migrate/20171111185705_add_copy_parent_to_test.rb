class AddCopyParentToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :copy_parent_id, :integer, null: true, index: true
  end
end
