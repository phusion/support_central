class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer   :support_source_id, null: false,
        on_update: :cascade, on_delete: :cascade
      t.string    :title, null: false
      t.integer   :status, null: false, default: 0
      t.text      :labels, array: true, default: []
      t.string    :display_id, null: false, foreign_key: false
      t.text      :data

      t.string    :external_id, null: false, foreign_key: false
      t.timestamp :external_last_update_time, null: false

      t.timestamps null: false
    end
  end
end
