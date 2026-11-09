# Media: a Runwell plugin

A library of each client's files and media, in folders. Every file Runwell already keeps for a
client (on the client, its work, the work's sections and its tasks) shows in the client's library,
where it can be put in folders, shared with the client or not, moved and deleted; files added in the
library go on the client.

- **Folders** in the sidebar, nested, each with how many files sit right in it: renamed, moved,
  deleted once empty. Drag a file onto a folder (in the sidebar or a folder's tile) to move it.
- **A sheet per file**: click a file and its sheet opens over the page (the address says which, so
  a link opens it too): a preview, its name (renaming the stored file), title, alt text, caption and
  credit, what it is and where it's kept, sharing, its folder, and deleting it.
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
