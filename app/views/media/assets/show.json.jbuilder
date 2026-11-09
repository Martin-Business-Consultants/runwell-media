asset = @document.media_asset
json.summary "#{@document.media_title} (#{@document.filename}) in #{@library.client.name}’s library"
json.document_id @document.id
json.filename @document.filename.to_s
json.extract! asset || Media::Asset.new, *Media::Asset::FIELDS
json.content_type @document.content_type
json.byte_size @document.byte_size
json.client_visible @document.client_visible
json.folder(@document.media_placement&.folder&.then { { id: it.id, path: it.path, locked: it.locked? } })
json.kept_on agent_ref(@document.documentable)
json.client agent_ref(@library.client)
json.url rails_blob_url(@document.file, disposition: :attachment)
