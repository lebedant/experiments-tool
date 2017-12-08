class Experiment::Variable < ApplicationRecord
  belongs_to :part, class_name: 'Experiment::Part'
  has_many :values, class_name: 'Experiment::Datum', dependent: :destroy

  validates_presence_of :name, :data_type
  validates :name, uniqueness: { scope: :part, message: "should be unique in Part context." }


  STRING = 0
  LONG = 1
  DOUBLE = 2

  TYPES = {
    string: STRING,
    long: LONG,
    double: DOUBLE
  }.freeze

  LOG_TRANSFORM = 0
  NORMAL_DIST = 1
  BINOMIAL_DIST = 2

  METHODS = {
    log_transformation: LOG_TRANSFORM,
    normal_distribution: NORMAL_DIST,
    binomial_distribution: BINOMIAL_DIST
  }.freeze

  as_enum :type, TYPES, source: :data_type
  as_enum :method, METHODS, source: :calculation_method

  #  ---- SCOPES ----
  default_scope { order(id: :asc) }
  scope :not_strings, -> { where.not(data_type: STRING) }


  def to_s
    name
  end

  def clear_data
    self.values.update_all(delete_reason: 'test')
  end

  def data
    values.map { |value| { value: value.target.value, delete_reason: value.delete_reason } }
  end

end
