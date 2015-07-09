json.array!(@products) do |product|
  json.extract! product, :id, :description, :precio, :cantidad
  json.url product_url(product, format: :json)
end
