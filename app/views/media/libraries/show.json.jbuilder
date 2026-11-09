json.summary "#{@client.name}’s library#{": #{@folder.path}" if @folder}#{" searched for “#{@filter.query}”" if @filter.searching?}: #{@folders.size} #{"folder".pluralize(@folders.size)}, #{@files.size} #{"file".pluralize(@files.size)}#{" (#{Media::Filter::KINDS[@filter.kind].downcase})" if @filter.kind}#{" here" unless @filter.searching?}"
json.query @filter.query
json.kind @filter.kind
json.client agent_ref(@client)
if @folder
  json.folder do
    json.extract! @folder, :id, :name, :parent_id
    json.path @folder.path
    json.locked @folder.locked?
    json.kept_from_client @folder.hidden?
  end
end
json.folders @folders do |folder|
  json.extract! folder, :id, :name
  json.kept_from_client folder.hidden?
  json.files @library.count_in(folder)
end
json.files @files do |document|
  json.document_id document.id
  json.filename document.filename.to_s
  json.content_type document.content_type
  json.kind Media::Filter.kind_of(document)
  json.folder_id document.media_placement&.folder_id
  json.byte_size document.byte_size
  json.client_visible document.client_visible
  json.kept_on agent_ref(document.documentable)
  json.url rails_blob_url(document.file, disposition: :attachment)
end
