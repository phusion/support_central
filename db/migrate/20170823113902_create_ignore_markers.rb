class CreateIgnoreMarkers < ActiveRecord::Migration
  def change
    create_table :ignore_markers do |t|
      t.string 'support_source_type', null: false
      t.string 'external_id', null: false, foreign_key: false
      t.timestamps null: false
    end

    add_index :ignore_markers, ['support_source_type', 'external_id'],
      unique: true
  end
end
