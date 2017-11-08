module TestsHelper
  def design_options
    Test::Part::DESIGN_TYPES.map { |key, val| [t(key), val] }
  end

  def data_type_options
    Test::Variable::DATA_TYPES.map { |key, val| [t(key), val] }
  end
end
