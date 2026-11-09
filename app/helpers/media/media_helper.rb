module Media
  module MediaHelper
    # What a browser can show in place: images (not SVG, which Active Storage serves as a download),
    # PDFs, video and audio.
    IMAGE_TYPES = %r{\Aimage/(png|jpeg|pjpeg|gif|webp|avif|bmp|x-icon|vnd\.microsoft\.icon|apng)\z}
    VIDEO_TYPES = %r{\Avideo/(mp4|webm|ogg|quicktime)\z}
    AUDIO_TYPES = %r{\Aaudio/(mpeg|mp3|mp4|aac|ogg|wav|x-wav|webm|flac|x-m4a)\z}

    def media_image?(document) = document.content_type.to_s.match?(IMAGE_TYPES)

    # How a file's sheet previews it: :image, :pdf, :video, :audio, or nil (its type, as a card).
    def media_preview(document)
      type = document.content_type.to_s
      if type.match?(IMAGE_TYPES) then :image
      elsif type == "application/pdf" then :pdf
      elsif type.match?(VIDEO_TYPES) then :video
      elsif type.match?(AUDIO_TYPES) then :audio
      end
    end

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
