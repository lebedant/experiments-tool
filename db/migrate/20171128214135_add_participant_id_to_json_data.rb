class AddParticipantIdToJsonData < ActiveRecord::Migration[5.1]
  def change
    add_reference :experiment_json_data, :participant, foreign_key: true
  end
end
