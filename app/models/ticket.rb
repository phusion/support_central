# == Schema Information
#
# Table name: tickets
#
#  id                :integer          not null, primary key
#  support_source_id :integer          not null
#  title             :string           not null
#  external_id       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  fk__tickets_support_source_id  (support_source_id)
#
# Foreign Keys
#
#  fk_tickets_support_source_id  (support_source_id => support_sources.id)
#

class Ticket < ActiveRecord::Base
  def external_url
    support_source.ticket_url(self)
  end
end
