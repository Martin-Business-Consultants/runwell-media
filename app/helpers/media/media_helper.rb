module Media
  module MediaHelper
    IMAGE_TYPES = %r{\Aimage/(png|jpeg|gif|webp|avif)\z}

    def media_image?(document) = document.content_type.to_s.match?(IMAGE_TYPES)

    # Where a file is kept, when it isn't on the client itself: "On Website rebuild".
    def media_origin(document)
      record = document.documentable
      case record
      when Client then nil
      when Work then "On #{record.title}"
      when ScopeItem then "On #{record.work.title}: #{record.description}"
      when Task then "On #{term(:task).downcase} “#{record.title}”"
      end
    end

    # The folders to move a file to: the top, then each folder by its path.
    def media_folder_options(library)
      [ [ "Top of the library", "" ] ] + library.folders.map { [ library.breadcrumbs(it).map(&:name).join(" / "), it.id ] }.sort_by { it.first.downcase }
    end

    def media_file_url(document, download: false)
      rails_blob_path(document.file, disposition: download ? :attachment : :inline)
    end
  end
end
