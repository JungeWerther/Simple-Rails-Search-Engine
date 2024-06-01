# lib/tasks/vectorize_products.rake
require 'net/http'
require 'json'
require 'hnswlib'

DIM = 384 
EMBEDDINGS_ENDPOINT = URI('https://api.openai.com/v1/embeddings') 
EE_HEADERS = { 
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{ENV['OPENAI_API_KEY']}"
}

def format_ee_data(text)
    # Format the body for the embeddings api call
    {
        "input" => text,
        "model" => "text-embedding-3-small"
    }.to_json
end

def get_embeddings(text)
    # Send a POST request to the embeddings endpoint
    response = Net::HTTP.post(EMBEDDINGS_ENDPOINT, format_ee_data(text), EE_HEADERS)
    JSON.parse(response.body)
end


namespace :vectorize_products do
  desc "Query all records, send data to an API, and create hnswlib vector index"
  task create_index: :environment do
    
    # Create hnswlib vector index
    index = Hnswlib::HierarchicalNSW.new(dim: DIM, space:'l2')
    index.init_index(max_elements: Product.all.size)

    # Query all records
    Product.all.each { |record|
        res = get_embeddings(record.name + "\n" + record.description)
        puts res
        index.add_point(res, record.id)
    }
    
    # Save the index to a file
    index.save('index.ann')
  end
end