class Test < ApplicationRecord
  self.per_page = 10

  validates_presence_of :name, :parts
  validates :name, uniqueness: true

  has_many :parts, class_name: 'Test::Part', dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :data, through: :parts, source: :data
  belongs_to :user
  # Recursive association for action "Copy"
  has_many :children, class_name: 'Test', foreign_key: "copy_parent_id"

  accepts_nested_attributes_for :parts, reject_if: :all_blank, allow_destroy: true

  default_scope { order(created_at: :desc) }

  # Enable nested copy
  amoeba do
    enable
    include_association :parts
    set state: :edit

    customize(lambda { |original, new_record|
      children_count = original.children.count + 1

      new_record.copy_parent_id = original.id
      new_record.name += " (#{children_count})"
    })
  end

  # Define states transitions
  state_machine :state, initial: :edit do
    event :to_test do
      transition :edit => :test
    end

    event :to_edit do
      transition :test => :edit
    end

    event :to_open do
      transition :test => :open
    end

    event :to_closed do
      transition :open => :closed
    end

    state :first_gear, :second_gear do
      validates_presence_of :seatbelt_on
    end

    after_transition on: :to_edit, do: :clear_data
  end


  def clear_data
    self.parts.each(&:clear_data)
  end

  def as_json(options)
    super(
      root: true,
      except: [:id, :user_id, :copy_parent_id, :created_at, :updated_at],
      include: {
        parts: {
          only: [:name, :access_token, :description],
          methods: :design,
          include: {
            variables: {
              only: [:name, :log_transform, :repetition_count],
              methods: [:type, :data]
            }
          }
        }
      }
    )
  end

end
