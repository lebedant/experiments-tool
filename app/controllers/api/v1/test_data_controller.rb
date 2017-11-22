module Api
  module V1
    class TestDataController < ActionController::API
      respond_to :json
      before_action :ensure_json_request
      before_action :find_test
      before_action :check_state
      before_action :find_participant, :check_params, only: :create
      # :check_repetition_count,

      def register_participant
        participant_data = {
          internal_id: SecureRandom.uuid,
          test_id: @test.id
        }

        # add external_id to data if it's supplied
        participant_data[:external_id] = params[:external_id] if params[:external_id]
        participant = Participant.create(participant_data)
        render json: { internal_id: participant.internal_id }
      end

      def create
        variable_params.each do |name, value|
          variable = find_variable_by(name)
          recordClass = "#{variable.type}_datum".classify.constantize
          record = recordClass.create(value: value)

          datum = Test::Datum.create(
            target_id: record.id,
            target_type: recordClass,
            participant_id: @participant.id,
            variable_id: variable.id
          )
        end

        # Save to json table
        Test::JsonDatum.create(test_id: @test.id, part_id: @current_part.id, data: variable_params)

        send_json_status('Ok', 200)
      end


      private

      def find_test
        @current_part = Test::Part.find_by!(access_token: params[:part_id])
        @test = @current_part.test
      rescue ActiveRecord::RecordNotFound
        send_json_status('Test part not found', 404)
      end

      def find_variable_by(name)
        Test::Variable.find_by!(
          name: name,
          part_id: @current_part.id
        )
      rescue ActiveRecord::RecordNotFound
        send_json_status("Variable with name '#{name}' not found", 404)
      end

      def find_participant
        find_options = if (params[:external_id])
                        { external_id: params[:external_id] }
                       else
                        { internal_id: params[:internal_id] }
                       end
        @participant = Participant.find_by!(find_options)
      rescue ActiveRecord::RecordNotFound
        send_json_status('Participant not found', 404)
      end

      def check_state
        if @test.edit? || @test.closed?
          send_json_status('Test is currently unavailable', 503)
        end
      end

      def check_params
        # check existance
        if !params[:variable_values]
          return send_json_status('Variable values are missing', 422)
        end
        # check type (must be Hash structure)
        unless variable_params.is_a? Hash
          return send_json_status('Variable_values must be Hash', 422)
        end
        # cjeck Hash size
        if variable_params.size != @current_part.variables.count
          return send_json_status('Size of variable_values is not correct', 422)
        end
      end

      def check_repetition_count
        existing_data = Test::Datum.where(
          variable_id: @variable.id,
          participant_id: @participant.id
        )

        if (existing_data.size >= @variable.repetition_count)
          send_json_status('Variable repetition count is exceeded', 422)
        end
      end

      def variable_params
        params.require(:variable_values).permit(params[:variable_values].keys).to_h
      end

      def ensure_json_request
        return if request.format == :json
        head :not_acceptable
      end

      def send_json_status(error, status)
        msg = { status: status, message: error }
        return render json: msg, status: status
      end

    end
  end
end