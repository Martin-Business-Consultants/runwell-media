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
        library = Media::Library.new(Media::Library.client_of(document))
        folder = library.folder(params[:folder_id]) if params[:folder_id].present?
        return redirect_back(fallback_location: media_library_path(library.client), alert: "That folder isn’t in #{library.client.name}’s library.") if params[:folder_id].present? && folder.nil?

        Media::Placement.move!(document, folder)
        notice = "#{document.media_title} moved to #{folder&.name || "the top of the library"}."
        # A file dragged onto a folder (the drop controller): the page redraws in place, with the notice.
        if request.format.turbo_stream?
          flash[:notice] = notice
          return render(turbo_stream: turbo_stream.refresh(request_id: nil))
        end

        redirect_to media_library_path(library.client, folder: folder&.id), notice: notice
      end
    end
  end
end
