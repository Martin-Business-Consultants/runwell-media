json.summary "#{@libraries.size} #{"library".pluralize(@libraries.size)}, #{@files.size} #{"file".pluralize(@files.size)}#{" matching" if @filter.narrowed?}"
json.query @filter.query
json.kind @filter.kind
json.libraries @libraries do |client|
  json.client agent_ref(client)
  json.files @file_counts.fetch(client.id, 0)
  json.folders @folder_counts.fetch(client.id, 0)
  json.url media_library_url(client)
end
json.files @files.first(Media::LibrariesController::FILE_LIMIT) do |document|
  json.document_id document.id
  json.filename document.filename.to_s
  json.title document.media_asset&.title
  json.content_type document.content_type
  json.kind Media::Filter.kind_of(document)
  json.byte_size document.byte_size
  json.client agent_ref(@library_of[document.id])
  json.client_visible document.client_visible
  json.kept_from_client document.media_placement&.folder_id.in?(@locked_folder_ids)
end
