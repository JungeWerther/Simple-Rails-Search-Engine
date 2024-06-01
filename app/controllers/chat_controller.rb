require_relative '../../app/services/Embeddings.rb'


class ChatController < ApplicationController
  def index
    if params[:query]
      results = EmbeddingsService.new.search_index(params[:query])
      @results = results.map { |result| Product.find(result) }
    else
      @results = []
    end
  end

  def search
    if request.post?
      redirect_to action: "index", query: params[:query]
    end
  end
end