class Test::Variable < ApplicationRecord
  belongs_to :part, class_name: 'Test::Part'
  has_many :values, class_name: 'Test::Datum'

  validates_presence_of :name, :data_type
  validates :name, uniqueness: { scope: :part, message: "should be unique in Part context." }
  validates :repetition_count, numericality: { greater_than: 0 }

  as_enum :type, %i{string long double}, source: :data_type

  #  ---- SCOPES ----
  default_scope { order(id: :asc) }
  scope :not_strings, -> { where.not(id: strings) }


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
