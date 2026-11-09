module Media
  # What the library's toolbar asks for: a search (q), one kind of file (kind: images, videos,
  # audio, documents or other; blank for all) and how folders and files are drawn (view: list, the
  # default, or grid). Applied to files already loaded (a library's, or every library's), in memory, as the
  # library itself works.
  class Filter
    KINDS = { "image" => "Images", "video" => "Videos", "audio" => "Audio", "document" => "Documents", "other" => "Other" }.freeze
    VIEWS = %w[list grid].freeze
    DOCUMENT_TYPES = %r{\A(text/|application/(pdf|msword|rtf|vnd\.ms-|vnd\.openxmlformats|vnd\.oasis\.opendocument|vnd\.apple\.))}

    attr_reader :query, :kind, :view

    def initialize(query: nil, kind: nil, view: nil)
      @query = query.to_s.squish.presence
      @kind = kind.to_s.presence_in(KINDS.keys)
      @view = view.to_s.presence_in(VIEWS) || "list"
    end

    def self.kind_of(document)
      case document.content_type.to_s
      when %r{\Aimage/} then "image"
      when %r{\Avideo/} then "video"
      when %r{\Aaudio/} then "audio"
      when DOCUMENT_TYPES then "document"
      else "other"
      end
    end

    def searching? = query.present?
    def narrowed? = searching? || kind.present?
    def list? = view == "list"

    # The files that match the search and the kind.
    def apply(documents) = searched(documents).select { kind.nil? || self.class.kind_of(it) == kind }

    # How many of the searched files are of each kind, and all of them ("" ⇒ all).
    def counts(documents)
      found = searched(documents)
      found.map { self.class.kind_of(it) }.tally.merge("" => found.size)
    end

    # Whether a name (a folder's, a library's) matches the search; everything does without one.
    def matches?(*texts) = !searching? || terms.all? { |term| texts.compact.any? { it.to_s.downcase.include?(term) } }

    # The address's params for these choices, with any changed (nil drops one).
    def params(**changes) = { q: query, kind: kind }.merge(changes).compact_blank

    private
      def terms = @terms ||= query.downcase.split

      def searched(documents)
        return documents unless searching?

        documents.select do |document|
          asset = document.media_asset
          matches?(document.filename.to_s, asset&.title, asset&.alt_text, asset&.caption, asset&.credit)
        end
      end
  end
end
