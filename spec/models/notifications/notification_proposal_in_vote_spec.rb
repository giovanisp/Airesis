require 'spec_helper'
require 'requests_helper'
require 'cancan/matchers'

describe NotificationProposalVoteStarts, type: :model, emails: true, notifications: true, seeds: true do
  it 'when the vote for the proposal starts sends correctly an email to all authors and participants' do
    user1 = create(:user)
    proposal = create(:public_proposal, current_user_id: user1.id, votation: { choise: 'new',
                                                                               start: 10.days.from_now,
                                                                               end: 14.days.from_now })
    participants = []
    2.times do
      user = create(:user)
      participants << user
      create(:positive_ranking, proposal: proposal, user: user)
      # proposal.proposal_presentations.create(user: user, acceptor: user1)
    end
    proposal.check_phase(true)
    proposal.reload

    expect(proposal.waiting?).to be_truthy

    proposal.vote_period.start_votation
    proposal.reload
    expect(proposal.voting?).to be_truthy

    expect(described_class.jobs.size).to eq 1
    described_class.drain
    AlertsWorker.drain
    EmailsWorker.drain

    deliveries = ActionMailer::Base.deliveries.last 3

    receivers = [participants[0], participants[1], user1]

    emails = deliveries.map { |m| m.to[0] }
    receiver_emails = receivers.map(&:email)
    expect(emails).to match_array receiver_emails

    expect(Alert.unscoped.count).to eq 3
    expect(Alert.last(3).map(&:user)).to match_array receivers
    expect(Alert.last(3).map { |a| a.notification_type.id }).to match_array [NotificationType::CHANGE_STATUS_MINE,
                                                                             NotificationType::CHANGE_STATUS,
                                                                             NotificationType::CHANGE_STATUS]
  end
end
