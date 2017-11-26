class CreateChartDefinitions < ActiveRecord::Migration[5.1]
  def change
    create_table :chart_definitions do |t|
        t.string :name
        t.jsonb :params
        t.belongs_to :experiment, index: true
    end
  end
end
