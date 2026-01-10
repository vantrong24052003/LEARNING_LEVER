# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostsController do
  let!(:user) { create(:user) }
  let!(:posts) { create_list(:post, 15, user:) }

  describe "GET #index" do
    it "returns a list of posts" do
      get :index

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body
      expect(json_response["data"]).to be_an(Array)
    end

    it "returns paginated posts with limit parameter" do
      get :index, params: { limit: 5 }

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body
      expect(json_response["data"].size).to eq(5)
    end

    it "returns empty array when no posts exist" do
      Post.destroy_all

      get :index

      expect(response).to have_http_status(:ok)
      json_response = response.parsed_body
      expect(json_response["data"]).to eq([])
    end
  end
end
