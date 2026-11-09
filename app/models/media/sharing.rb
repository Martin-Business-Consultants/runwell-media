module Media
  # The rule on the core's Document (through its load hook): a file in a folder kept from the
  # client can't be shared, wherever the switch is flipped (the library, a work's Documents, an
  # agent), so a locked folder never leaks into the portal. It holds while the plugin is switched
  # off too: a lock someone set shouldn't lapse unseen.
  module Sharing
    extend ActiveSupport::Concern

    included do
      has_one :media_placement, class_name: "Media::Placement", dependent: :delete
      validate :media_folder_allows_sharing, if: -> { client_visible? && will_save_change_to_client_visible? }
    end

    def media_folder = media_placement&.folder

    private
      def media_folder_allows_sharing
        return unless media_folder&.locked?

        errors.add(:base, "#{filename} is in #{media_folder.path}, which is kept from the client: move it out or unlock the folder to share it")
      end
  end
end
