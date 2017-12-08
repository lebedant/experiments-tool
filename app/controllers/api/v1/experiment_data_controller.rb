class Api::V1::ExperimentDataController < ActionController::API
  respond_to :json
  before_action :ensure_json_request
  before_action :set_cors_headers
  before_action :find_participant, :find_experiment, :check_state, :check_params, :check_repetition_count, only: :create


  def register_participant
    participant_data = {
      internal_id: SecureRandom.uuid
    }

    # add external_id to data if it's supplied
    participant_data[:external_id] = params[:external_id] if params[:external_id]
    participant = Participant.create(participant_data)

    render json: { internal_id: participant.internal_id }
  end

  def create
    # [ {name: "age", value: "77"}, ..., ... ]
    flat_json = {}

    variable_params.each do |variable_row|
      variable = find_variable_by(variable_row[:name]) or return

      recordClass = "#{variable.type}_datum".classify.constantize
      record = recordClass.create(value: variable_row[:value])

      datum = Experiment::Datum.create(
        target_id: record.id,
        target_type: recordClass,
        participant_id: @participant.id,
        variable_id: variable.id
      )

      flat_json[variable_row[:name]] = variable_row[:value]
    end

    # Save to json table
    Experiment::JsonDatum.create(
      experiment_id: @experiment.id,
      part_id: @current_part.id,
      participant_id: @participant.id,
      data: flat_json
    )

    send_json_status('Ok', 200)
  end


  private

  def find_experiment
    @current_part = Experiment::Part.find_by!(access_token: params[:part_id])
    @experiment = @current_part.experiment
  rescue ActiveRecord::RecordNotFound
    return send_json_status('Experiment part not found', 404)
  end

  def find_variable_by(name)
    Experiment::Variable.find_by!(
      name: name,
      part_id: @current_part.id
    )
  rescue ActiveRecord::RecordNotFound
    send_json_status("Variable with name '#{name}' not found", 404) and return
  end

  def find_participant
    find_options = if (params[:external_id])
                    { external_id: params[:external_id] }
                   else
                    { internal_id: params[:internal_id] }
                   end
    @participant = Participant.find_by!(find_options)
  rescue ActiveRecord::RecordNotFound
    return send_json_status('Participant not found', 404)
  end

  def check_state
    if @experiment.edit? || @experiment.closed?
      return send_json_status('Experiment is currently unavailable', 503)
    end
  end

  def check_params
    # check existance
    if !params[:variable_values]
      return send_json_status('variable_values are missing', 422)
    end
    # check type (must be Hash structure)
    unless variable_params.is_a? Array
      return send_json_status('variable_values must be Array', 422)
    end
    # cjeck Hash size
    if variable_params.size != @current_part.variables.count
      return send_json_status('Size of variable_values is not correct', 422)
    end
  end

  def check_repetition_count
    existing_data = Experiment::JsonDatum.where(
      part_id: @current_part.id,
      participant_id: @participant.id
    )

    if (existing_data.size >= @current_part.repetition_count)
      return send_json_status('Variable repetition count is exceeded', 422)
    end
  end

  def variable_params
    params.permit(variable_values: [:name, :value]).to_h[:variable_values]
  end

  def set_cors_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = '*'
    # response.headers['X-ComanyName-Api-Version'] = 'V1'
  end

  def ensure_json_request
    return if request.format == :json
    head :not_acceptable
  end

  def send_json_status(message, status)
    msg = { status: status, message: message }
    return render json: msg, status: status
  end

end
