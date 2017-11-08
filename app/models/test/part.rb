class Test::Part < ApplicationRecord
  belongs_to :test
  has_many :variables, class_name: 'Test::Variable', dependent: :destroy
  has_secure_token :access_token

  validates_presence_of :name, :variables

  accepts_nested_attributes_for :variables, reject_if: :all_blank, allow_destroy: true

  DESIGN_TYPES = {
    within_subject: 0,
    between_subject: 1
  }

  def variables_to_s
    variables.map(&:to_s).join(', ')
  end

end
