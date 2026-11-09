# A client's library: folders (media_folders, nested, each possibly kept from the client) and which
# folder each of its files sits in (media_placements). The files themselves are the core's
# Documents, pointed at by id; a file in no folder sits at the top of its client's library.
class CreateMediaTables < ActiveRecord::Migration[8.1]
  def change
    create_table :media_folders do |t|
      t.integer :client_id, null: false
      t.integer :parent_id
      t.string :name, null: false
      t.boolean :hidden, null: false, default: false
      t.integer :created_by_id
      t.timestamps
    end
    add_index :media_folders, %i[client_id parent_id]

    create_table :media_placements do |t|
      t.integer :document_id, null: false
      t.integer :folder_id, null: false
      # Shared when its folder (or one above) was kept from the client, so unlocking shares it again.
      t.boolean :shared_before_lock, null: false, default: false
      t.timestamps
    end
    add_index :media_placements, :document_id, unique: true
    add_index :media_placements, :folder_id
  end
end
