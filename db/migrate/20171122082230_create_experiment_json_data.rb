class CreateExperimentJsonData < ActiveRecord::Migration[5.1]
  def change
    create_table :experiment_json_data do |t|
      t.belongs_to :part, index: true
      t.belongs_to :test, index: true
      t.jsonb :data
    end
  end
end
