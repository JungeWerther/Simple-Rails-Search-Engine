# Chat with your products
1. Make sure you have exported OPENAI_API_KEY as environment variable.
1. Make sure you have sqlite, ruby, bundler installed (see standard Rails installation)
1. Run ```bundle install```
1. (Optional, only when batch importing products from the backend) Run 
```bundle exec rake vectorize_products:create_index``` 
to create the index for the products table
1. `rails s` to deploy
