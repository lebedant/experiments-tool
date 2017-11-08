class Test < ApplicationRecord
  validates_presence_of :name, :parts
  has_many :parts, class_name: 'Test::Part', dependent: :destroy
  has_many :participants, dependent: :destroy
  belongs_to :user

  accepts_nested_attributes_for :parts, reject_if: :all_blank, allow_destroy: true

  default_scope { order(created_at: :desc) }
end
