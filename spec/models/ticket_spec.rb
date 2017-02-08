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

require 'rails_helper'

RSpec.describe Ticket, type: :model do
end
