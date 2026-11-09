module Media
  # Media: every library and every file in them (index), and one client's library, folder by
  # folder (show, ?folder=). Both take the toolbar's search (q), kind of file (kind) and view (grid
  # or list, remembered for next time).
  class LibrariesController < ApplicationController
    # The most files the Media page draws at once: a search or a kind narrows the rest.
    FILE_LIMIT = 120

    allow_staff
    agent_tool :list_media_libraries, on: :index, title: "List clients' media libraries",
      description: "Every client with how many files and folders their library has, and the newest files across every library. q searches file names, titles, alt text and captions (and libraries by client name); kind narrows the files to image, video, audio, document or other. show_media_library opens one.",
      params: { q: "string", kind: "string" }
    agent_tool :show_media_library, on: :show, title: "Show a client's media library",
      description: "A client's files (every Document on the client, its work, sections and tasks) arranged in folders: folder_id for one folder (blank: the top). Each file says whether the client sees it; each folder whether it's kept from the client (locked: nothing in it reaches their portal). q searches the whole library (file names, titles, alt text, captions, folder names); kind narrows the files to image, video, audio, document or other.",
      params: { folder_id: "integer", q: "string", kind: "string" }

    before_action :set_filter

    def index
      @clients = Client.where(status: "active").order(Arel.sql("internal DESC, lower(name)")).to_a
      @folder_counts = Media::Folder.group(:client_id).count
      @locked_folder_ids = Media::Folder.locked_ids(@clients.map(&:id))
      pairs = Media::Library.across(@clients)
      @file_counts = pairs.map { it.last.id }.tally
      @library_of = pairs.to_h { [ it.first.id, it.last ] }
      documents = pairs.map(&:first)
      @kind_counts = @filter.counts(documents)
      @files = @filter.apply(documents)
      @libraries = @clients.select { @filter.matches?(it.name) }
      @shelf = Media::Shelf.new(@clients)
    end

    def show
      @client = Client.find(params[:client_id])
      @library = Media::Library.new(@client)
      folder_id = params[:folder_id].presence || params[:folder].presence
      @folder = @library.folder(folder_id) if folder_id
      # A search looks through the whole library; otherwise it's the open folder's.
      base = @filter.searching? ? @library.documents : @library.documents_in(@folder)
      @kind_counts = @filter.counts(base)
      @files = @filter.apply(base)
      @folders = @filter.searching? ? @library.folders.select { @filter.matches?(it.name) } : @library.folders_in(@folder)
      @shelf = Media::Shelf.active
    end

    private
      def set_filter
        view = params[:view].to_s.presence_in(Media::Filter::VIEWS)
        cookies.permanent[:media_view] = view if view
        @filter = Media::Filter.new(query: params[:q], kind: params[:kind], view: view || cookies[:media_view])
      end
  end
end
