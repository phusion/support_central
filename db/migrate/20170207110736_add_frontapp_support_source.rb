class AddFrontappSupportSource < ActiveRecord::Migration
  def change
    add_column :support_sources, :frontapp_user_id, :string, foreign_key: false
    add_column :support_sources, :frontapp_auth_token, :string
    add_column :support_sources, :frontapp_inbox_ids, :text, array: true, default: []
  end
end
