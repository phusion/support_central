# == Schema Information
#
# Table name: tickets
#
#  id                        :integer          not null, primary key
#  support_source_id         :integer          not null
#  title                     :string           not null
#  labels                    :text             default([]), is an Array
#  external_id               :string
#  external_last_update_time :datetime         not null
#  status                    :integer          default(0), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  fk__tickets_support_source_id  (support_source_id)
#

class Ticket < ActiveRecord::Base
  enum status: { normal: 0, respond_now: 1, overdue: 2 }

  def external_url
    support_source.ticket_url(self)
  end
end
