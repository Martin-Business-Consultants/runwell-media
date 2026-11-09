module Media
  # A client's library: every file the core keeps for them (on the client itself, its work, the
  # work's sections and its tasks: Documents), arranged in its folders. Staff see it all; the
  # client's view (for_client) is only what's shared, in folders not kept from them.
  class Library
    attr_reader :client

    def initialize(client, client_view: false)
      @client, @client_view = client, client_view
    end

    def self.for_client(client) = new(client, client_view: true)

    def client_view? = @client_view

    # Every one of the client's files, newest first, with what it's on and its folder.
    def documents
      @documents ||= begin
        scope = @client_view ? client.client_documents : all_documents
        scope.includes(:documentable, :uploaded_by, :media_placement, file_attachment: :blob).to_a
      end
    end

    def folders
      @folders ||= begin
        all = client.media_folders.ordered.to_a
        @client_view ? all.reject { locked_in?(it, all) } : all
      end
    end

    def folder(id) = folders.find { it.id.to_s == id.to_s }

    # The folders directly inside folder (nil: the top), and the files in it.
    def folders_in(folder) = folders.select { it.parent_id == folder&.id }
    def documents_in(folder) = documents.select { it.media_placement&.folder_id == folder&.id || (folder.nil? && placed_out_of_view?(it)) }

    # How many files are in a folder and every folder inside it.
    def count_in(folder)
      ids = subtree(folder).map(&:id)
      documents.count { ids.include?(it.media_placement&.folder_id) }
    end

    # The client's view shows a folder only when something shared is in it, however deep.
    def shown?(folder) = !@client_view || count_in(folder).positive?

    def breadcrumbs(folder) = folder ? chain(folder) : []

    private
      def all_documents
        works = client.works.select(:id)
        Document.where(documentable: client)
          .or(Document.where(documentable_type: "Work", documentable_id: works))
          .or(Document.where(documentable_type: "ScopeItem", documentable_id: ScopeItem.where(work_id: works).select(:id)))
          .or(Document.where(documentable_type: "Task", documentable_id: Task.where(client_id: client.id).select(:id)))
          .recent
      end

      def subtree(folder)
        found, frontier = [ folder ], [ folder ]
        while frontier.any?
          frontier = folders.select { |candidate| frontier.any? { candidate.parent_id == it.id } }
          found.concat(frontier)
        end
        found
      end

      def chain(folder)
        all = folders.index_by(&:id)
        list, current = [], folder
        while current && list.size < 50
          list.unshift(current)
          current = all[current.parent_id]
        end
        list
      end

      def locked_in?(folder, all)
        by_id = all.index_by(&:id)
        current, depth = folder, 0
        while current && depth < 50
          return true if current.hidden?

          current, depth = by_id[current.parent_id], depth + 1
        end
        false
      end

      # A shared file in a folder the client can't see (it can't be, by the lock rule, but a folder
      # deleted under it, say): the client finds it at the top rather than not at all.
      def placed_out_of_view?(document)
        placement = document.media_placement
        @client_view && placement && folders.none? { it.id == placement.folder_id }
      end
  end
end
