class AddRssSupportSources < ActiveRecord::Migration
  def up
    add_column :support_sources, :rss_url, :string
    change_column :tickets, :display_id, :string, null: true, foreign_key: false
  end

  def down
    remove_column :support_sources, :rss_url
    change_column :tickets, :display_id, :string, null: false, foreign_key: false
  end
end
