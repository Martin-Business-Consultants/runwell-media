module Media
  module Documents
    # A file moved to another folder of its client's library (or the top). Into a folder kept from
    # the client, a shared file stops being shared.
    class MovesController < Media::ApplicationController
      allow_staff
      agent_tool :move_media_file, on: :create, title: "Move a file to another media folder",
        description: "document_id: the file (show_media_library lists them); folder_id: where it goes (blank: the top of the library). Moved into a locked folder, a shared file is unshared.",
        params: { folder_id: "integer" }

      def create
        document = Document.find(params[:document_id])
        library = Media::Library.new(client_of(document))
        folder = library.folder(params[:folder_id]) if params[:folder_id].present?
        return redirect_back(fallback_location: media_library_path(library.client), alert: "That folder isn’t in #{library.client.name}’s library.") if params[:folder_id].present? && folder.nil?

        Media::Placement.move!(document, folder)
        redirect_to media_library_path(library.client, folder: folder&.id), notice: "#{document.filename} moved to #{folder&.name || "the top of the library"}."
      end

      private
        def client_of(document)
          record = document.documentable
          record.is_a?(Client) ? record : (record.try(:client) || record.try(:work)&.client) || raise(ActiveRecord::RecordNotFound)
        end
    end
  end
end
