class NotificationProposalReadyForVote < NotificationSender

  def perform(proposal_id)
    elaborate(proposal_id)
  end

  #send alerts when the debate is closed and the authors must choose a date for the votation
  def elaborate(proposal_id)
    proposal = Proposal.find(proposal_id)
    group = proposal.group
    data = {'proposal_id' => proposal.id.to_s, 'title' => proposal.title, 'i18n' => 't', 'extension' => 'wait'}
    if proposal.in_group?
      data['group'] = group.name
      data['subdomain'] = group.subdomain if group.certified?
    end
    notification_a = Notification.new(notification_type_id: NotificationType::CHANGE_STATUS_MINE, url: url_for_proposal(proposal, group), data: data)
    notification_a.save
    proposal.users.each do |user|
      send_notification_for_proposal(notification_a, user, proposal)
    end
  end
end
