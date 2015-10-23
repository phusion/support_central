class CreateSupportSources < ActiveRecord::Migration
  def change
    create_table :support_sources do |t|
      t.string :type, null: false
      t.string :name, null: false
      t.integer :user_id, null: false,
        on_update: :cascade, on_delete: :cascade
      t.timestamps null: false

      ## GithubSupportSource
      t.string :github_owner_and_repo

      ## SupportbeeSupportSource
      t.string :supportbee_company_id, foreign_key: false
      t.string :supportbee_auth_token
      t.string :supportbee_user_id, foreign_key: false
      t.text :supportbee_group_ids, array: true, default: []
    end
  end
end
