class ChartDefinitionsController < ApplicationController

  def create
    @definition = ChartDefinition.new(setting_params)
    experiment = Experiment.find(setting_params[:experiment_id])

    if @definition.save
      flash[:notice] = 'Chart settings was successfully created.'
    end

    redirect_to experiment
  end

  def destroy
  end


  private

    def setting_params
      params.require(:chart_definition).permit(
        :name,
        :experiment_id,
        :target_variable,
        :calculate_method,
        :filter_variable,
        filter_variable_values: []
      )
    end
end
