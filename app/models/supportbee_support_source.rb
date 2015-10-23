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
#  supportbee_group_ids  :text             default([]), is an Array
#
# Indexes
#
#  fk__support_sources_user_id  (user_id)
#

class SupportbeeSupportSource < SupportSource
  validates :supportbee_company_id, :supportbee_auth_token, :supportbee_user_id,
    :supportbee_group_ids, presence: true

  def ticket_url(ticket)
    "https://#{supportbee_company_id}.supportbee.com/tickets/#{ticket.external_id}"
  end
end
