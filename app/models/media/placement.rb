module Media
  # Which folder of its client's library a file (a core Document) sits in. A file with none sits at
  # the top. Moving a shared file into a folder kept from the client unshares it (remembered, so
  # unlocking shares it again).
  class Placement < ApplicationRecord
    self.table_name = "media_placements"

    belongs_to :document
    belongs_to :folder, class_name: "Media::Folder"

    # Puts the document in folder (nil: the top of the library).
    def self.move!(document, folder)
      transaction do
        placement = find_by(document_id: document.id)
        if folder.nil?
          placement&.destroy!
          return
        end

        placement ||= new(document: document)
        placement.update!(folder: folder, shared_before_lock: false)
        if folder.locked? && document.client_visible?
          placement.update!(shared_before_lock: true)
          document.update!(client_visible: false)
        end
      end
    end
  end
end
