# == Schema Information
#
# Table name: tickets
#
#  id                        :integer          not null, primary key
#  support_source_id         :integer          not null
#  title                     :string           not null
#  status                    :integer          default(0), not null
#  labels                    :text             default([]), is an Array
#  display_id                :string           not null
#  data                      :text
#  external_id               :string           not null
#  external_last_update_time :datetime         not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  fk__tickets_support_source_id  (support_source_id)
#
# Foreign Keys
#
#  fk_tickets_support_source_id  (support_source_id => support_sources.id) ON DELETE => cascade ON UPDATE => cascade
#

class Ticket < ActiveRecord::Base
  enum status: { normal: 0, respond_now: 1, overdue: 2 }

  def display_id_with_hash_prefix
    result = display_id
    if result =~ /^\d/
      result = "##{result}"
    end
    result
  end

  def external_url
    support_source.external_url(self)
  end
end
