# Media: a Runwell plugin

A library of each client's files and media, in folders. Every file Runwell already keeps for a
client (on the client, its work, the work's sections and its tasks) shows in the client's library,
where it can be put in folders, shared with the client or not, moved and deleted; files added in the
library go on the client.

- **Every file at once**: the Media page shows every file across the libraries, newest first, the
  libraries and their folders in the sidebar. A search box at the top (file names, titles, alt text, captions; and
  libraries by name) and a pill per kind of file (images, videos, audio, documents, other, with
  counts) narrow it; in a library the same toolbar searches the whole library or filters the open
  folder. Files show as a list (the default) or as tiles: each person's choice, remembered.
- **Folders** in a sidebar on every Media page: every library as a drop-down, its folders nested
  inside as drop-downs of their own, each with how many files it holds, opened down to the folder on
  screen. Folders are renamed, moved, deleted once empty. Drag a file onto a folder of its library
  (in the sidebar or a folder's tile) to move it.
- **A sheet per file**: click a file and its sheet opens over the page (the address says which, so
  a link opens it too): a preview (an image, a PDF's pages, a video or audio player), its name (renaming the stored file), title, alt text, caption and
  credit, what it is and where it's kept, sharing, its folder, and deleting it.
- **Private by default**: files added here are never shared, and every new folder starts kept from
  the client; open a folder to them to share what's in it.
- **Kept from the client**: lock a folder and nothing in it, however deep, reaches the client's
  portal. Files shared there are unshared (and remembered: unlocking shares them again), and none
  can be shared while it's locked, wherever the switch is flipped (the rule is on the core's
  Document, through its load hook), so a locked folder never leaks.
- **Portal**: a Library page in the client's portal, the shared files in their folders.
- **Agents**: `list_media_libraries`, `show_media_library`, `create_media_folder`,
  `update_media_folder`, `delete_media_folder`, `lock_media_folder`, `unlock_media_folder`,
  `upload_media_files`, `move_media_file`, `show_media_file`, `update_media_file`, and
  `portal_library` for a client's agent.

Requires Runwell 5.12 or later. Install it from Settings > Plugins with
`Martin-Business-Consultants/runwell-media`, then switch it on.

The plugin owns `media_folders`, `media_placements` and `media_assets` (a file's details); the files stay the core's Documents, so
removing the plugin leaves every file on its record.
