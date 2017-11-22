class Test::Part < ApplicationRecord
  belongs_to :test
  has_many :variables, class_name: 'Test::Variable', dependent: :destroy
  has_many :data, through: :variables, source: :values
  has_many :json_data, class_name: 'Test::JsonDatum'

  accepts_nested_attributes_for :variables, reject_if: :all_blank, allow_destroy: true

  as_enum :design, %i{within_subject between_subject}, source: :design_type

  validates_presence_of :name, :variables
  validates :name, uniqueness: { scope: :test, message: 'should be unique in Test context.' }

  before_save :generate_access_token

  # enable nested copy
  amoeba do
    enable
    nullify :access_token
    include_association :variables
  end

  def to_s
    name
  end

  def variables_to_s
    variables.map(&:to_s).join(', ')
  end

  def generate_access_token
    self.access_token = "#{test.name.parameterize}-#{name.parameterize}"
  end

  def clear_data
    self.variables.each(&:clear_data)
  end

  def as_json(options)
    super(except: [:id, :test_id, :created_at, :updated_at], include: :variables)
  end

end
