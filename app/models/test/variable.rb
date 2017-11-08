class Test::Variable < ApplicationRecord
  belongs_to :part, class_name: 'Test::Part'
  has_many :values, class_name: 'Test::Datum'

  validates_presence_of :name, :data_type

  DATA_TYPES = {
    string: 0,
    long: 1,
    double: 2
  }

  def to_s
    name
  end

end
