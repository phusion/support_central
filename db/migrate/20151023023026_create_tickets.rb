class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.integer :support_source_id, null: false,
        on_update: :cascade, on_delete: :cascade
      t.string :title, null: false
      t.string :external_id, foreign_key: false
      t.timestamps null: false
    end
  end
end
