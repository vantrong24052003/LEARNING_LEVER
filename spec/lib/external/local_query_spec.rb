require 'rails_helper'

RSpec.describe External::LocalQuery do
  describe "#search" do
    let!(:published_post) { create(:post, title: "Rails 8 Released", status: :published) }
    let!(:draft_post) { create(:post, title: "Drafting Rails 9", status: :draft) }
    let!(:archived_post) { create(:post, title: "Old Rails 5", status: :archived) }

    it "searches by category (status)" do
      service = described_class.new
      results = service.search(query: nil, category: "published")

      expect(results.size).to eq(1)
      expect(results.first[:title]).to eq("Rails 8 Released")
      expect(results.first[:status]).to eq("published")
    end

    it "searches by query (title keyword)" do
      service = described_class.new
      results = service.search(query: "Rails", category: nil)

      expect(results.size).to eq(3)
    end

    it "searches by both query and category" do
      service = described_class.new
      results = service.search(query: "9", category: "draft")

      expect(results.size).to eq(1)
      expect(results.first[:title]).to eq("Drafting Rails 9")
    end
  end
end
