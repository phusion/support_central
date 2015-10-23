# == Schema Information
#
# Table name: support_sources
#
#  id                    :integer          not null, primary key
#  type                  :string           not null
#  name                  :string           not null
#  user_id               :integer          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  github_owner_and_repo :string
#  supportbee_company_id :string
#  supportbee_auth_token :string
#  supportbee_user_id    :string
#  supportbee_group_id   :integer
#
# Indexes
#
#  fk__support_sources_user_id  (user_id)
#
# Foreign Keys
#
#  fk_support_sources_user_id  (user_id => users.id)
#

require 'spec_helper'

describe GithubSupportSource do
  pending "add some examples to (or delete) #{__FILE__}"
end
