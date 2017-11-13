class AddDeleteReasonToTestDatum < ActiveRecord::Migration[5.1]
  def change
    add_column :test_data, :delete_reason, :string
  end
end
