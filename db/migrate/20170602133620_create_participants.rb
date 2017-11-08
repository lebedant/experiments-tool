class CreateParticipants < ActiveRecord::Migration[5.1]
  def change
    create_table :participants do |t|
      t.string :internal_id
      t.string :external_id
      t.references :test, foreign_key: true

      t.timestamps
    end
  end
end
