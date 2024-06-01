require 'net/http'
require 'json'
require 'hnswlib'

INDEX_PATH = 'lib/assets/index.ann'
OPENAI_API_KEY = ENV['OPENAI_API_KEY']
DIM = 1536
EMBEDDINGS_ENDPOINT = URI('https://api.openai.com/v1/embeddings') 
EE_HEADERS = { 
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{OPENAI_API_KEY}"
}

class EmbeddingsService
    def initialize
        @index = Hnswlib::HierarchicalNSW.new(space: 'l2', dim: DIM)
        begin
            @index.load_index(INDEX_PATH)
        rescue
            create_index
        end
        puts "[INDEX]"
    end

    def format_ee_data(text)
        # Formats data for OpenAI API
        {
            "input" => text,
            "model" => "text-embedding-3-small"
        }.to_json
    end

    def get_embeddings(text)
        # Gets embeddings from OpenAI API
        if text.nil? then return nil end
        response = Net::HTTP.post(EMBEDDINGS_ENDPOINT, format_ee_data(text), EE_HEADERS)
        parsed = JSON.parse(response.body)
        if parsed['error'] then return nil end
        parsed['data'][0]['embedding']
    end

    def create_index
        # Creates a vector index using hnswlib
        @index.init_index(max_elements: Product.all.size)

        Product.all.each { |record|
            res = get_embeddings(record.name + "\n" + record.description)
            @index.add_point(res, record.id)
        }
        @index.save_index(INDEX_PATH)
    end

    def search_index(text)
        # Searches the index for the most similar records
        res = get_embeddings(text)
        if res.nil? then return [] end
        @index.search_knn(res, 5)[0]
    end
end