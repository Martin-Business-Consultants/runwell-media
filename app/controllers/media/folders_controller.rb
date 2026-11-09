module Media
  # Folders in a client's library: made, renamed or moved into another, and deleted once empty.
  class FoldersController < ApplicationController
    allow_staff
    agent_tool :create_media_folder, on: :create, title: "Add a folder to a client's media library",
      description: "parent_id: the folder it goes in (blank: the top). New folders are open to the client; lock_media_folder keeps one from them.",
      params: { client_id: "integer!", folder: { name: "string!", parent_id: "integer" } }
    agent_tool :update_media_folder, on: :update, title: "Rename or move a media folder",
      description: "parent_id moves it into another folder of the same library (blank: the top).",
      params: { folder: { name: "string", parent_id: "integer" } }
    agent_tool :delete_media_folder, on: :destroy, title: "Delete an empty media folder",
      description: "Only once nothing is in it: move its files (move_media_file) and folders out first."

    def create
      client = Client.find(params[:client_id])
      folder = client.media_folders.new(folder_params.merge(created_by: Current.user))
      if folder.save
        client.record_event!("media.folder_created", payload: { folder: folder.path })
        redirect_to media_library_path(client, folder: folder.id), notice: "#{folder.name} added."
      else
        redirect_back fallback_location: media_library_path(client), alert: folder.errors.full_messages.to_sentence
      end
    end

    def update
      folder = Media::Folder.find(params[:id])
      if folder.update(folder_params)
        redirect_to media_library_path(folder.client, folder: folder.id), notice: "#{folder.name} saved."
      else
        redirect_back fallback_location: media_library_path(folder.client, folder: folder.id), alert: folder.errors.full_messages.to_sentence
      end
    end

    def destroy
      folder = Media::Folder.find(params[:id])
      folder.destroy_empty!
      folder.client.record_event!("media.folder_deleted", payload: { folder: folder.path })
      redirect_to media_library_path(folder.client, folder: folder.parent_id), notice: "#{folder.name} deleted."
    rescue Media::Folder::Refused => error
      redirect_back fallback_location: media_library_path(folder.client, folder: folder.id), alert: error.message
    end

    private
      def folder_params
        attributes = params.expect(folder: %i[name parent_id])
        attributes[:parent_id] = attributes[:parent_id].presence if attributes.key?(:parent_id)
        attributes
      end
  end
end
