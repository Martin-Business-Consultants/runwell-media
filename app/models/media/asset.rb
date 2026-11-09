module Media
  # A file's details in the library (its sheet): a title to show instead of the file name, alt text
  # describing an image for anyone who can't see it, a caption and a credit. The file itself, and
  # its name, are the core Document's; renaming it renames the stored file (the extension kept).
  class Asset < ApplicationRecord
    self.table_name = "media_assets"

    FIELDS = %i[title alt_text caption credit].freeze

    belongs_to :document
    belongs_to :updated_by, class_name: "User", optional: true

    normalizes :title, :alt_text, :credit, with: ->(value) { value.to_s.squish.presence }
    normalizes :caption, with: ->(value) { value.to_s.strip.presence }
    validates :title, :credit, length: { maximum: 200 }
    validates :alt_text, length: { maximum: 500 }
    validates :caption, length: { maximum: 2_000 }

    # The details for a document, kept or new (not saved until something's set).
    def self.for(document) = document.media_asset || new(document: document)

    # Saves the details and, when given, a new file name (the extension is the file's own, kept).
    def update_with_filename(attributes, filename: nil, by: Current.user)
      transaction do
        assign_attributes(attributes.merge(updated_by: by))
        save! if changed? && (persisted? || FIELDS.any? { self[it].present? })
        rename_file!(filename) if filename.present?
      end
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    private
      def rename_file!(name)
        blob = document.file.blob
        extension = blob.filename.extension_with_delimiter
        base = name.to_s.strip.delete_suffix(extension).gsub(%r{[/\\\\]}, "-").squish
        return if base.blank? || "#{base}#{extension}" == blob.filename.to_s

        blob.update!(filename: "#{base}#{extension}")
      end
  end
end
