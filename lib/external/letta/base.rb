# frozen_string_literal: true

module External
  module Letta
    class Base
      def initialize(base_url:, api_key: nil)
        @base_url = base_url
        @api_key = api_key
      end

      private

      def get_request(path)
        Integration::Util::HttpClient.get(endpoint: "#{@base_url}#{path}", headers:)
      rescue StandardError => e
        raise External::Letta::Client::Error, "Letta API Error: #{e.message}"
      end

      def post_request(path, body)
        Integration::Util::HttpClient.post(endpoint: "#{@base_url}#{path}", body:,
                                           headers: headers.merge("Content-Type" => "application/json"),)
      rescue StandardError => e
        raise External::Letta::Client::Error, "Letta API Error: #{e.message}"
      end

      def headers
        header_data = {}
        header_data["Authorization"] = "Bearer #{@api_key}" if @api_key.present?
        header_data
      end
    end
  end
end
