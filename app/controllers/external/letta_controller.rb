# frozen_string_literal: true

module External
  class LettaController < ApplicationController
    skip_forgery_protection only: :create

    def create
      service = External::LettaService.new

      result = if tool_execution_request?
                 service.execute_tools(params)
               else
                 service.execute(params)
               end

      if result[:error]
        render_error(error: result[:error], status: result[:status])
      else
        render_success(response: result[:response])
      end
    rescue StandardError => e
      render_error(error: e.message)
    end

    private

    def tool_execution_request?
      params.key?(:tool_calls)
    end
  end
end
