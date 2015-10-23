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

require 'spec_helper'

describe Ticket do
  pending "add some examples to (or delete) #{__FILE__}"
end
