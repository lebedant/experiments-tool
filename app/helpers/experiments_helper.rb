module ExperimentsHelper

  def prefill_variables
    {
      time: {
              name: t(:variable_time),
              data_type: Experiment::Variable::DOUBLE,
              calculation_method: Experiment::Variable::LOG_TRANSFORM
            },
      error: {
               name: t(:variable_error),
               data_type: Experiment::Variable::LONG,
               calculation_method: Experiment::Variable::BINOMIAL_DIST
             },
      scale: {
               name: t(:variable_scale),
               data_type: Experiment::Variable::LONG,
               calculation_method: Experiment::Variable::NORMAL_DIST
             },
      filter: {
                name: t(:variable_filter),
                data_type: Experiment::Variable::STRING,
                calculation_method: nil
              }
    }
  end

  def is_need_prefill(object, field)
    object.new_record? && object.send(field).nil?
  end

  def object_value(object, field, prefill)
    is_need_prefill(object, field) ? prefill[field] : object.send(field)
  end

end
