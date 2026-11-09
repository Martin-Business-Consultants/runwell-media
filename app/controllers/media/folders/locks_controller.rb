module Media
  module Folders
    # A folder kept from the client (locked) or opened to them again. Locking unshares what's in it;
    # unlocking shares again what locking unshared, so it reaches the client.
    class LocksController < Media::ApplicationController
      allow_staff
      agent_tool :lock_media_folder, on: :create, title: "Keep a media folder from the client",
        description: "It and everything in it, however deep, stops reaching the client's portal: files shared there are unshared (and remembered), and none can be shared while it's locked."
      agent_tool :unlock_media_folder, on: :destroy, title: "Open a media folder to the client again",
        description: "The files locking it unshared are shared again, unless a folder above is still locked.",
        confirm: "Unlocking shows the files that were shared before it was locked to the client in their portal again."

      before_action { @folder = Media::Folder.find(params[:folder_id]) }

      def create
        @folder.lock!
        redirect_to media_library_path(@folder.client, folder: @folder.id), notice: "#{@folder.name} is kept from #{@folder.client.name}: nothing in it reaches their portal."
      end

      def destroy
        @folder.unlock!
        redirect_to media_library_path(@folder.client, folder: @folder.id), notice: "#{@folder.name} is open to #{@folder.client.name} again: what was shared in it is shared again."
      end
    end
  end
end
