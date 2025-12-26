# frozen_string_literal: true

module Renderable
  def render_success(response: nil, status: :ok)
    render json: { data: response }, status:
  end

  def render_error(error: nil, response: nil, status: :internal_server_error)
    if response.present?
      render json: { error:, data: response }, status:
    else
      render json: { error: }, status:
    end
  end
end
