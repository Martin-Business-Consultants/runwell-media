module Media
  # Media: every client's library (index), and one client's, folder by folder (show, ?folder=).
  class LibrariesController < ApplicationController
    allow_staff
    agent_tool :list_media_libraries, on: :index, title: "List clients' media libraries",
      description: "Every client with how many folders their library has. show_media_library opens one."
    agent_tool :show_media_library, on: :show, title: "Show a client's media library",
      description: "A client's files (every Document on the client, its work, sections and tasks) arranged in folders: folder_id for one folder (blank: the top). Each file says whether the client sees it; each folder whether it's kept from the client (locked: nothing in it reaches their portal).",
      params: { folder_id: "integer" }

    def index
      @clients = Client.where(status: "active").order(Arel.sql("internal DESC, lower(name)")).to_a
      @folder_counts = Media::Folder.group(:client_id).count
    end

    def show
      @client = Client.find(params[:client_id])
      @library = Media::Library.new(@client)
      @folder = @library.folder(params[:folder_id] || params[:folder]) if (params[:folder_id] || params[:folder]).present?
    end
  end
end
