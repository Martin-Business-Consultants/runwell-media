json.summary "#{@clients.size} #{"library".pluralize(@clients.size)}"
json.libraries @clients do |client|
  json.client agent_ref(client)
  json.folders @folder_counts.fetch(client.id, 0)
  json.url media_library_url(client)
end
