json.array!(@support_sources) do |support_source|
  json.extract! support_source, :id
  json.url support_source_url(support_source, format: :json)
end
