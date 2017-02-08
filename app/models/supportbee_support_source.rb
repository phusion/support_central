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
#  frontapp_user_id      :string
#  frontapp_auth_token   :string
#  frontapp_inbox_ids    :text             default([]), is an Array
#
# Indexes
#
#  fk__support_sources_user_id                (user_id)
#  index_support_sources_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_support_sources_user_id  (user_id => users.id) ON DELETE => cascade ON UPDATE => cascade
#

class SupportbeeSupportSource < SupportSource
  validates :supportbee_company_id, :supportbee_auth_token, :supportbee_user_id,
    :supportbee_group_ids, presence: true

  default_value_for :name, 'Supportbee'

  def external_url(ticket)
    "https://#{supportbee_company_id}.supportbee.com/tickets/#{ticket.external_id}"
  end

  def supportbee_group_ids_as_string
    supportbee_group_ids.join(',')
  end

  def supportbee_group_ids_as_string=(value)
    self.supportbee_group_ids = value.to_s.
      split(',').
      reject { |x| x.blank? }.
      map { |x| x.strip }
  end

  def scheduler
    SupportbeeScheduler.instance
  end
end
