module Media
  # A file's sheet in the library: opened over the page from its tile (?asset= on the library's
  # address, loaded into the sheet's frame), its details edited in place: name, title, alt text,
  # caption and credit, beside sharing, its folder and deleting it.
  class AssetsController < ApplicationController
    allow_staff
    agent_tool :show_media_file, on: :show, title: "Show a file in a media library",
      description: "id: the file's document id (show_media_library lists them). Its name, title, alt text, caption, credit, size, folder, where it's kept and whether the client sees it."
    agent_tool :update_media_file, on: :update, title: "Change a media file's details",
      description: "filename renames the stored file (its extension stays); title is shown instead of the file name; alt_text describes an image for anyone who can't see it; caption and credit as they'd be printed. Blank clears one.",
      params: { asset: { filename: "string", title: "string", alt_text: "string", caption: "text", credit: "string" } }

    before_action :set_document

    def show
      respond_to do |format|
        format.html do
          next redirect_to(media_library_path(@library.client, folder: @document.media_placement&.folder_id, asset: @document.id)) unless turbo_frame_request?

          render layout: false
        end
        format.json
      end
    end

    def update
      details = params.expect(asset: [ :filename, *Media::Asset::FIELDS ])
      @asset = Media::Asset.for(@document)
      if @asset.update_with_filename(details.except(:filename).to_h.symbolize_keys, filename: details[:filename])
        @document.reload
        # Saved in the sheet (its frame follows the redirect and shows it saved); anyone else (an
        # agent) goes back to the library with the notice.
        return redirect_to(media_asset_path(@document, saved: 1)) if turbo_frame_request?

        redirect_to media_library_path(@library.client, folder: @document.media_placement&.folder_id), notice: "#{@document.media_title} saved."
      else
        return redirect_to(media_asset_path(@document, error: @asset.errors.full_messages.to_sentence)) if turbo_frame_request?

        redirect_back fallback_location: media_library_path(@library.client), alert: @asset.errors.full_messages.to_sentence
      end
    end

    private
      def set_document
        @document = Document.includes(:media_asset, :media_placement, file_attachment: :blob).find(params[:id])
        @library = Media::Library.new(Media::Library.client_of(@document))
      end
  end
end
