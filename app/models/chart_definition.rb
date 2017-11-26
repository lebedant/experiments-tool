class ChartDefinition < ActiveRecord::Base
  serialize :params
  store_accessor :params, :target_variable, :calculate_method, :filter_variable, :filter_variable_values

  validates :name, uniqueness: true

  # default_scope { order(id: :desc) }
end