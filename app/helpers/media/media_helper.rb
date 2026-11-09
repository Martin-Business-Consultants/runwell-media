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

    # "3 files · 2 folders": what's right in a folder, as opening it shows.
    def media_folder_summary(library, folder)
      [ pluralize(library.count_in(folder), "file"), (pluralize(library.folders_in(folder).size, "folder") if library.folders_in(folder).any?) ].compact.join(" · ")
    end

    # The plugin's own icons, drawn as the core's are (16×16, stroked in currentColor): the core
    # has no folder or list among them.
    MEDIA_ICONS = {
      folder: '<path d="M1.75 4.25a1 1 0 0 1 1-1h3.4l1.5 1.5h5.6a1 1 0 0 1 1 1v6.5a1 1 0 0 1-1 1H2.75a1 1 0 0 1-1-1z"/>',
      list: '<path d="M5.5 4h8M5.5 8h8M5.5 12h8M2.5 4h.5M2.5 8h.5M2.5 12h.5"/>'
    }.freeze

    def media_icon(name, css: nil)
      tag.svg(MEDIA_ICONS.fetch(name).html_safe, class: [ "icon", "media-icon--#{name}", css ], viewBox: "0 0 16 16", aria: { hidden: true })
    end

    # A toolbar link: the page's path with these params (blank ones dropped).
    def media_toolbar_path(path, params)
      query = params.compact_blank.to_query
      query.empty? ? path : "#{path}?#{query}"
    end

    def media_file_url(document, download: false)
      rails_blob_path(document.file, disposition: download ? :attachment : :inline)
    end
  end
end
