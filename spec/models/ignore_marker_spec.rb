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

require 'rails_helper'

RSpec.describe IgnoreMarker, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
