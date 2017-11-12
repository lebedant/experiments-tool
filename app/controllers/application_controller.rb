class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  @@actions = nil

  def self.allowed_ghost_actions(methods)
    @@actions = methods
  end

  def respond_to?(method, include_private = false)
    (@@actions.include?(method) if !@@actions.nil?) || super
  end

  def render_404(options={})
    render_error({:message => :notice_file_not_found, :status => 404}.merge(options))
    return false
  end
end
