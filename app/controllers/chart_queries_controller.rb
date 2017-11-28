class ChartQueriesController < ApplicationController
  before_action :find_query, only: :destroy

  def create
    @query = ChartQuery.new(query_params)

    if @query.save
      flash[:notice] = 'Chart query was successfully created.'
    end

    redirect_to @query.experiment
  end

  def destroy
    @query.destroy
    flash[:notice] = 'Chart query was successfully destroyed.'
    redirect_to @experiment
  end


  private

    def find_query
      @query = ChartQuery.find(params[:id])
      @experiment = @query.experiment
    rescue ActiveRecord::RecordNotFound
      render_404
    end

    def query_params
      params.require(:chart_query).permit(
        :name,
        :experiment_id,
        :target_variable,
        :calculate_method,
        :filter_variable,
        filter_variable_values: []
      )
    end
end
