# What the library knows about a file beyond the file itself: its title, alt text (for images),
# caption and credit, edited in the file's sheet. One row per core Document, made the first time
# one of them is set.
class CreateMediaAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :media_assets do |t|
      t.integer :document_id, null: false
      t.string :title
      t.string :alt_text
      t.text :caption
      t.string :credit
      t.integer :updated_by_id
      t.timestamps
    end
    add_index :media_assets, :document_id, unique: true
  end
end
