class RenameExperimentStates < ActiveRecord::Migration[5.1]
  def up
    Experiment.where(state: 'test').update_all(state: 'debug')
  end

  def down
    # do nothing
  end
end
