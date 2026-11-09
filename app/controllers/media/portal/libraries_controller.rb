module Media
  module Portal
    # The client's Library in their portal: what's shared with them, in the folders not kept from
    # them, folder by folder (?folder=).
    class LibrariesController < ::Portal::BaseController
      agent_tool :portal_library, on: :show, title: "Your library",
        description: "The files shared with you, in their folders: folder_id for one folder (blank: the top).",
        params: { folder_id: "integer" }

      before_action { head :not_found unless Runwell::Plugins.enabled?(:media) }

      def show
        @library = Media::Library.for_client(client)
        id = params[:folder_id].presence || params[:folder].presence
        @folder = @library.folder(id) if id
      end
    end
  end
end
