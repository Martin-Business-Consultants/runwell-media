module Media
  # A folder in a client's library, inside another or at the top. Kept from the client (hidden):
  # it and everything under it is staff only. Its files can't be shared while it is (the rule is on
  # Document, Media::Sharing), and locking it unshares those that were, remembering them, so
  # unlocking shares them again. A folder is deleted only when nothing is in it.
  class Folder < ApplicationRecord
    self.table_name = "media_folders"

    # A move its state doesn't allow (deleting a folder with files or folders in it), in words.
    class Refused < StandardError; end

    belongs_to :client
    belongs_to :parent, class_name: "Media::Folder", optional: true
    belongs_to :created_by, class_name: "User", optional: true
    has_many :children, class_name: "Media::Folder", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error
    has_many :placements, class_name: "Media::Placement", dependent: :restrict_with_error

    normalizes :name, with: ->(name) { name.to_s.squish }
    validates :name, presence: true, length: { maximum: 80 }
    validate :parent_in_same_library

    scope :ordered, -> { order(Arel.sql("lower(name)")) }

    # Every folder of its library, by id, read once (the tree is walked in memory, not a query a level).
    def library_folders = @library_folders ||= Media::Folder.where(client_id: client_id).index_by(&:id)

    # Every folder above it, the top one first.
    def ancestors
      chain, folder = [], library_folders[parent_id]
      while folder && chain.size < 50
        chain.unshift(folder)
        folder = library_folders[folder.parent_id]
      end
      chain
    end

    def path = (ancestors + [ self ]).map(&:name).join(" / ")

    # Kept from the client, by itself or by a folder above it.
    def locked? = hidden? || ancestors.any?(&:hidden?)

    # It and every folder inside it, however deep.
    def subtree_ids
      ids, frontier = [ id ], [ id ]
      while frontier.any? && ids.size < 10_000
        frontier = library_folders.values.select { it.parent_id.in?(frontier) }.map(&:id)
        ids.concat(frontier)
      end
      ids
    end

    # The folders kept from their client, by themselves or a folder above, in one client's library
    # or several (an id or a list).
    def self.locked_ids(client_ids)
      folders = where(client_id: client_ids).index_by(&:id)
      folders.values.select { |folder|
        current, depth = folder, 0
        current, depth = folders[current.parent_id], depth + 1 until current.nil? || current.hidden? || depth > 50
        current&.hidden?
      }.map(&:id).to_set
    end

    def empty? = children.none? && placements.none?

    # Kept from the client: its files that were shared stop being, remembered for unlocking.
    def lock!(by: Current.user)
      return if hidden?

      transaction do
        update!(hidden: true)
        @library_folders = nil
        Media::Placement.where(folder_id: subtree_ids).includes(:document).find_each do |placement|
          next unless placement.document.client_visible?

          placement.update!(shared_before_lock: true)
          placement.document.update!(client_visible: false)
        end
        client.record_event!("media.folder_locked", actor: by, payload: { folder: path })
      end
    end

    # Open to the client again: the files it unshared are shared again, unless a folder above
    # still keeps them.
    def unlock!(by: Current.user)
      return unless hidden?

      transaction do
        update!(hidden: false)
        @library_folders = nil
        still_locked = Media::Folder.locked_ids(client_id)
        Media::Placement.where(folder_id: subtree_ids, shared_before_lock: true).includes(:document).find_each do |placement|
          next if still_locked.include?(placement.folder_id)

          placement.update!(shared_before_lock: false)
          placement.document.update!(client_visible: true)
        end
        client.record_event!("media.folder_unlocked", actor: by, payload: { folder: path })
      end
    end

    def destroy_empty!
      raise Refused, "#{name} still has files or folders in it: move or delete them first." unless empty?

      destroy!
    end

    private
      def parent_in_same_library
        return unless parent

        errors.add(:parent, "is in another library") if parent.client_id != client_id
        errors.add(:parent, "can’t be the folder itself or one inside it") if persisted? && parent_id.in?(subtree_ids)
      end
  end
end
