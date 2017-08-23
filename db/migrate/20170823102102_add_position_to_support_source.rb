class AddPositionToSupportSource < ActiveRecord::Migration
  def change
    add_column :support_sources, :position, :integer
  end
end
