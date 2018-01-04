class ChartQuery < ApplicationRecord
  serialize :params
  store_accessor :params, :target_variable, :calculate_method, :filter_variable, :filter_variable_values

  belongs_to :experiment
  validates :name, uniqueness: true

  default_scope { order(id: :desc) }
end