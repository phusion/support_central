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

require 'rails_helper'

RSpec.describe Ticket, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
