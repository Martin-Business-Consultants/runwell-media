json.summary "#{@client.name}’s library#{": #{@folder.path}" if @folder}: #{@library.folders_in(@folder).size} folders, #{@library.documents_in(@folder).size} files here"
json.client agent_ref(@client)
if @folder
  json.folder do
    json.extract! @folder, :id, :name, :parent_id
    json.path @folder.path
    json.locked @folder.locked?
    json.kept_from_client @folder.hidden?
  end
end
json.folders @library.folders_in(@folder) do |folder|
  json.extract! folder, :id, :name
  json.kept_from_client folder.hidden?
  json.files @library.count_in(folder)
end
json.files @library.documents_in(@folder) do |document|
  json.document_id document.id
  json.filename document.filename.to_s
  json.content_type document.content_type
  json.byte_size document.byte_size
  json.client_visible document.client_visible
  json.kept_on agent_ref(document.documentable)
  json.url rails_blob_url(document.file, disposition: :attachment)
end
