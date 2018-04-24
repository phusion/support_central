# == Schema Information
#
# Table name: ignore_markers
#
#  id                  :integer          not null, primary key
#  support_source_type :string           not null
#  external_id         :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_ignore_markers_on_support_source_type_and_external_id  (support_source_type,external_id) UNIQUE
#

class IgnoreMarker < ApplicationRecord
  def self.ignore(tickets)
    transaction do
      tickets.each do |ticket|
        find_or_create_by(
          support_source_type: ticket.support_source.class.to_s,
          external_id: ticket.external_id)
      end
    end
  end
end
