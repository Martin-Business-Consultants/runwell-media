json.summary "#{@folder ? @folder.name : "Your library"}: #{@library.documents_in(@folder).size} files"
json.folders @library.folders_in(@folder).select { @library.shown?(it) } do |folder|
  json.extract! folder, :id, :name
  json.files @library.count_in(folder)
end
json.files @library.documents_in(@folder) do |document|
  json.filename document.filename.to_s
  json.content_type document.content_type
  json.byte_size document.byte_size
  json.url rails_blob_url(document.file, disposition: :attachment)
end
