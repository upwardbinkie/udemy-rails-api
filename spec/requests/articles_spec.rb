# frozen_string_literal: true

require "rails_helper"

RSpec.describe(ArticlesController) do
  describe "#index" do
    it "returns a success response" do
      get "/articles"
      # expect(response.status).to eq('200')
      expect(response).to(have_http_status(:ok))
    end

    it "returns a proper JSON" do
      article = create(:article)
      get "/articles"
      expect(json_data.length).to(eq(1))
      expected = json_data.first
      aggregate_failures do
        expect(expected[:id]).to(eq(article.id.to_s))
        expect(expected[:type]).to(eq("article"))
        expect(expected[:attributes]).to(eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        ))
      end
    end

    it "returns articles in proper order" do
      older_article = create(:article, created_at: 1.hour.ago)
      recent_article = create(:article)
      get "/articles"
      ids = json_data.map { |item| item[:id].to_i }
      expect(ids).to(
        eq([recent_article.id, older_article.id])
      )
    end

    it "paginates results" do
      _article1, article2, _article3 = create_list(:article, 3)
      get "/articles", params: { page: { number: 2, size: 1 } }
      expect(json_data.length).to(eq(1))
      expect(json_data.first[:id]).to(eq(article2.id.to_s))
    end

    it "contains pagination links in the response" do
      _article1, _article2, _article3 = create_list(:article, 3)
      get "/articles", params: { page: { number: 2, size: 1 } }
      expect(json[:links].length).to(eq(5))
      expect(json[:links].keys).to(contain_exactly(:first, :prev, :next, :last, :self))
    end
  end

  describe "#show" do
    let(:article) { create :article }

    subject { get "/articles/#{article.id}" }

    before { subject }

    it "returns a success response" do
      expect(response).to(have_http_status(:ok))
    end

    it "returns a proper JSON" do
      aggregate_failures do
        expect(json_data[:id]).to(eq(article.id.to_s))
        expect(json_data[:type]).to(eq("article"))
        expect(json_data[:attributes]).to(eq(
          title: article.title,
          content: article.content,
          slug: article.slug
        ))
      end
    end
  end

  describe "#create", type: :controller do
    subject { post :create }

    context "when no code provided" do
      it_behaves_like "forbidden_requests"
    end

    context "when invalid code provided" do
      before { request.headers["authorization"] = "Invalid token" }
      it_behaves_like "forbidden_requests"
    end

    context "when authorized" do
      let(:access_token) { create :access_token }
      before { request.headers["authorization"] = "Bearer #{access_token.token}" }

      context "when invalid parameters provided" do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                tittle: "",
                content: "",
              },
            },
          }
        end

        subject { post :create, params: invalid_attributes }

        it "should return 422 status code" do
          subject
          expect(response).to(have_http_status(:unprocessable_entity))
        end

        it "should return proper error json" do
          subject
          expect(json["errors"]).to(include(
            {
              "source" => { "pointer" => "/data/attributes/title" },
              "detail" => "can't be blank",
            },
            {
              "source" => { "pointer" => "/data/attributes/content" },
              "detail" => "can't be blank",
            },
            {
              "source" => { "pointer" => "/data/attributes/slug" },
              "detail" => "can't be blank",
            }
          ))
        end
      end
    end
  end
end
