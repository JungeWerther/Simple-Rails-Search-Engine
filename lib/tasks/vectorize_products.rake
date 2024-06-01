# lib/tasks/vectorize_products.rake
require_relative '../../app/services/Embeddings.rb'

namespace :vectorize_products do
  desc "Query all records, send data to an API, and create hnswlib vector index"
  task create_index: :environment do
    EmbeddingsService.new.create_index
  end
end