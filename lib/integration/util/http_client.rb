# frozen_string_literal: true

module Integration
  module Util
    class HttpClient
      DEFAULT_OPEN_TIMEOUT = 60
      DEFAULT_READ_TIMEOUT = 120

      class << self
        def get(endpoint:, params: nil, headers: {}, **)
          request = build_request(Net::HTTP::Get, endpoint, params:, headers:)
          send_request(request, **)
        end

        def post(endpoint:, body: nil, params: nil, headers: {}, **)
          request = build_request(Net::HTTP::Post, endpoint, params:, headers:)
          request.body = format_body(body, headers) if body.present?
          send_request(request, **)
        end

        def put(endpoint:, body: nil, params: nil, headers: {}, **)
          request = build_request(Net::HTTP::Put, endpoint, params:, headers:)
          request.body = format_body(body, headers) if body.present?
          send_request(request, **)
        end

        def patch(endpoint:, body: nil, params: nil, headers: {}, **)
          request = build_request(Net::HTTP::Patch, endpoint, params:, headers:)
          request.body = format_body(body, headers) if body.present?
          send_request(request, **)
        end

        def delete(endpoint:, params: nil, headers: {}, **)
          request = build_request(Net::HTTP::Delete, endpoint, params:, headers:)
          send_request(request, **)
        end

        private

        def build_request(request_class, endpoint, params:, headers:)
          uri = build_uri(endpoint, params)
          request = request_class.new(uri)
          set_headers(request, headers)
          request
        end

        def build_uri(endpoint, params)
          uri = URI.parse(endpoint.to_s)
          uri.query = URI.encode_www_form(params) if params.present?
          uri
        end

        def set_headers(request, custom_headers)
          custom_headers.each { |name, value| request[name] = value } if custom_headers.present?
        end

        def format_body(body, headers)
          return body if body.is_a?(String)

          content_type = headers["Content-Type"]
          if content_type&.include?("x-www-form-urlencoded")
            URI.encode_www_form(body)
          else
            JSON.generate(body)
          end
        end

        def send_request(request, **options)
          http = Net::HTTP.new(request.uri.host, request.uri.port)
          http.use_ssl      = request.uri.scheme == "https"
          http.open_timeout = options[:open_timeout] || DEFAULT_OPEN_TIMEOUT
          http.read_timeout = options[:read_timeout] || DEFAULT_READ_TIMEOUT

          response = http.request(request)
          response.value # Raises error for non-2xx responses

          parse_response(response)
        rescue Net::HTTPError,
               Net::HTTPRetriableError,
               Net::HTTPClientException,
               Net::HTTPFatalError => e
          handle_http_error(e)
        rescue JSON::ParserError
          response.body
        end

        def parse_response(response)
          return nil if response.body.blank?

          if response.content_type&.include?("json")
            JSON.parse(response.body)
          else
            response.body
          end
        end

        def handle_http_error(exception)
          response_body = exception.response&.body
          Rails.logger.error("[HttpClient] #{exception.class} #{exception.message} response_body=#{response_body}")
          raise exception
        end
      end
    end
  end
end
