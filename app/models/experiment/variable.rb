class Experiment::Variable < ApplicationRecord
  belongs_to :part, class_name: 'Experiment::Part'
  has_many :values, class_name: 'Experiment::Datum'

  validates_presence_of :name, :data_type
  validates :name, uniqueness: { scope: :part, message: "should be unique in Part context." }


  STRING = 0
  LONG = 1
  DOUBLE = 2

  ENUM = {
    string: STRING,
    long: LONG,
    double: DOUBLE
  }.freeze

  as_enum :type, ENUM, source: :data_type

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
    values.map { |value| value.target.value.to_f }
  end

end
