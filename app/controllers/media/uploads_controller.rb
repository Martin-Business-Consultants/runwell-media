module Media
  # Files added to a client's library, into a folder or at the top: Documents on the client (the
  # core's), internal until someone shares them.
  class UploadsController < ApplicationController
    allow_staff
    agent_tool :upload_media_files, on: :create, title: "Add files to a client's media library",
      description: "folder_id: the folder they go in (blank: the top). They're internal until shared (set_document_visibility).",
      params: { client_id: "integer!", folder_id: "integer", document: { files: "file!" } }

    def create
      client = Client.find(params[:client_id])
      folder = client.media_folders.find_by(id: params[:folder_id]) if params[:folder_id].present?
      files = Array(params.dig(:document, :files)).compact_blank
      return redirect_back(fallback_location: media_library_path(client), alert: "Choose a file to upload.") if files.empty?

      documents = files.map { client.documents.new(file: it, uploaded_by: Current.user, client_visible: false) }
      if (refused = documents.find(&:invalid?))
        return redirect_back fallback_location: media_library_path(client), alert: "#{refused.filename} #{refused.errors[:file].to_sentence}."
      end

      Document.transaction do
        documents.each(&:save!)
        documents.each { Media::Placement.move!(it, folder) } if folder
      end
      client.record_event!("document.added", payload: { files: documents.map { it.filename.to_s }, folder: folder&.path }.compact)
      redirect_to media_library_path(client, folder: folder&.id), notice: "#{helpers.pluralize(documents.size, "file")} added#{" to #{folder.name}" if folder}."
    end
  end
end
