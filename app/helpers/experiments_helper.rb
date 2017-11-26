module ExperimentsHelper

  def prefill_variables
    {
      time: {
              name: "Complition time",
              data_type: Experiment::Variable::DOUBLE,
              log_transform: true
            },
      error: {
               name: "Error rate",
               data_type: Experiment::Variable::LONG,
               log_transform: false
             },
      scale: {
               name: "Likert scale rate",
               data_type: Experiment::Variable::LONG,
               log_transform: false
             },
      filter: {
                name: "Filter variable",
                data_type: Experiment::Variable::STRING,
                log_transform: false
              }
    }
  end

  def is_need_prefill(object, field)
    object.new_record? && object.send(field).nil?
  end

end
