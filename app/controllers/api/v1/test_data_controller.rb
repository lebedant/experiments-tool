module Api
  module V1
    class TestDataController < ActionController::API
      respond_to :json
      acts_as_token_authentication_handler_for User

      before_action :ensure_json_request

      def register_participant
        part = Test::Part.where(access_token: participant_params[:part_id]).first

        if part
          participant_data = {
            internal_id: SecureRandom.uuid,
            test_id: part.test_id
          }
          participant_data[:external_id] = participant_params[:external_id] if participant_params[:external_id]

          participant = Participant.create(participant_data)
          render json: { internal_id: participant.internal_id }
        else
          render json: { error: 'Test part not found' }, status: :not_found
        end
      end

      def create
        # current_user
        # params => json :
        #  -> access_token for TestPart
        #  + data: variable name (must be uniq in the part context)
        #          variable type must match its defined type

        part = Test::Part.where(access_token: data_params[:part_id]).first
        test = current_user.tests.find(part.test_id)

        if test.nil? || data_params[:variable_name].nil? || data_params[:variable_value].nil? || data_params[:internal_id].nil?
          msg = { error: "Missing usefull params like variable name and its value." }
          return render json: msg, status: 400
        end

        variable = Test::Variable.where(name: data_params[:variable_name], part_id: part.id).first
        participant = Participant.where(internal_id: data_params[:internal_id]).first
        # TODO:
        recordClass =  case data_params[:variable_value].class.name
                        when "Integer"
                          LongDatum
                        when "Float"
                          DobleDatum
                        when "String"
                          StringDatum
                        end

        record = recordClass.create(value: data_params[:variable_value])

        datum = Test::Datum.create(
          target_id: record.id,
          target_type: recordClass,
          participant_id: participant.id,
          variable_id: variable.id
        )

        render json: "ok", status: :ok
      end



      private

      def ensure_json_request
        return if request.format == :json
        head :not_acceptable
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def participant_params
        params.permit(:part_id, :external_id)
      end

      def data_params
        params.permit(:part_id, :external_id, :internal_id, :variable_name, :variable_value)
      end

    end
  end
end