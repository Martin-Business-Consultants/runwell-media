module Media
  # The sidebar on every Media page: each active client's library with its folders, nested, and how
  # many files each holds. Read in a few queries for every library at once (never one a library),
  # since the sidebar shows them all, whichever page is open.
  class Shelf
    attr_reader :clients

    def initialize(clients)
      @clients = clients
    end

    def self.active = new(Client.where(status: "active").order(Arel.sql("internal DESC, lower(name)")).to_a)

    # The folders directly inside parent (nil: a library's top).
    def folders_in(client, parent) = children.fetch([ client.id, parent&.id ], [])

    def folders?(client) = folders_by_client.key?(client.id)

    # How many files a library holds, wherever they're kept.
    def total_for(client) = library_counts.fetch(client.id, 0)

    # How many files sit right in a folder; at a library's top, those in no folder.
    def count_in(client, folder)
      folder ? folder_counts.fetch(folder.id, 0) : total_for(client) - folders_by_client.fetch(client.id, []).sum { folder_counts.fetch(it.id, 0) }
    end

    # Whether a folder is kept from the client, by itself or a folder above.
    def locked?(folder) = locked_ids.include?(folder.id)

    # The folder's id and every folder above it: the drop-downs open to show it.
    def open_ids(folder)
      ids = []
      while folder && ids.size < 50
        ids << folder.id
        folder = folders_by_id[folder.parent_id]
      end
      ids
    end

    private
      def folders = @folders ||= Media::Folder.where(client_id: clients.map(&:id)).ordered.to_a
      def folders_by_id = @folders_by_id ||= folders.index_by(&:id)
      def folders_by_client = @folders_by_client ||= folders.group_by(&:client_id)
      def children = @children ||= folders.group_by { [ it.client_id, it.parent_id ] }

      def folder_counts
        @folder_counts ||= Media::Placement.joins(:document).where(folder_id: folders_by_id.keys).group(:folder_id).count
      end

      def library_counts = @library_counts ||= Media::Library.counts(clients)

      def locked_ids
        @locked_ids ||= folders.select { |folder|
          current, depth = folder, 0
          current, depth = folders_by_id[current.parent_id], depth + 1 until current.nil? || current.hidden? || depth > 50
          current&.hidden?
        }.map(&:id).to_set
      end
  end
end
