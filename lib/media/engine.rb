module Media
  # A library of each client's files, in folders (README.md). The files are the core's Documents,
  # wherever they're kept (the client, its work, sections and tasks); the plugin owns only its
  # folders (media_folders) and where each file sits (media_placements), pointing at core records
  # by id, and reaches the core only through the plugin contract (docs/plugin-contract.md in
  # Runwell). Remove it and Runwell runs as before, every file still on its record.
  class Engine < ::Rails::Engine
    initializer "media.routes" do |app|
      app.routes.append do
        scope "media", module: "media", as: "media" do
          get "/", to: "libraries#index", as: :libraries
          get "clients/:client_id", to: "libraries#show", as: :library
          resources :folders, only: %i[create update destroy] do
            resource :lock, only: %i[create destroy], module: :folders
          end
          resources :uploads, only: :create
          resources :assets, path: "files", only: %i[show update]
          resources :documents, only: [] do
            resource :move, only: :create, module: :documents
          end
        end
        get "portal/library", to: "media/portal/libraries#show", as: :media_portal_library
      end
    end

    initializer "media.models" do
      ActiveSupport.on_load(:runwell_client) { has_many :media_folders, class_name: "Media::Folder", dependent: :delete_all }
      ActiveSupport.on_load(:runwell_document) { include Media::Sharing }
    end

    initializer "media.helpers" do
      ActiveSupport.on_load(:action_view) { include Media::MediaHelper }
    end

    config.to_prepare do
      Runwell::Plugins.register :media, name: "Media", version: Media::VERSION, author: "Martin Business Consultants",
        enabled_by_default: false, requires: ">= 5.12.0", homepage: "https://github.com/Martin-Business-Consultants/runwell-media",
        description: "A library of each client's files and media, in folders: everything already kept on the client, its work and tasks, arranged and shared from one place. Folders can be kept from the client, so nothing in them reaches the portal; clients browse what's shared in a Library page of their portal."
      Runwell::Plugins.nav :media, "Media", -> { media_libraries_path }, icon: "picture-add"
      Runwell::Plugins.slot :client_panel, :media, "media/slots/client_panel"
      # In the portal the library is the client's Documents, standing in for the core's flat list
      # (Runwell 5.13); an older core keeps its Documents and gets a Library beside it.
      if Runwell::Plugins.method(:portal_nav).parameters.any? { it.last == :replaces }
        Runwell::Plugins.portal_nav :media, "Documents", -> { media_portal_library_path }, replaces: :documents
      else
        Runwell::Plugins.portal_nav :media, "Library", -> { media_portal_library_path }
      end
      Runwell::Plugins.stylesheet :media, "media/media"
    end
  end
end
