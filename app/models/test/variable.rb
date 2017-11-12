class Test::Variable < ApplicationRecord
  belongs_to :part, class_name: 'Test::Part'
  has_many :values, class_name: 'Test::Datum'

  validates_presence_of :name, :data_type
  validates :name, uniqueness: { scope: :part, message: "should be unique in Part context." }

  as_enum :type, %i{string long double}, source: :data_type


  default_scope { order(id: :asc) }

  def to_s
    name
  end

  def clear_data
    self.values.delete_all
  end

  def data
    values.map {|value| value.target.value }
  end

end
