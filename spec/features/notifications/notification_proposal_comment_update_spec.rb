require 'spec_helper'
require 'requests_helper'
require "cancan/matchers"

describe 'notifications when a proposal comment is updated', type: :feature do

  it "sends correctly an email all people which ranked the comment" do
    user1 = create(:user)
    group = create(:group, current_user_id: user1.id)
    proposal = create(:group_proposal, quorum: BestQuorum.public.first, current_user_id: user1.id, group_proposals: [GroupProposal.new(group: group)])

    participants = []
    5.times do
      user = create(:user)
      participants << user
      create_participation(user, group)
    end


    contribute = create(:proposal_comment, proposal: proposal, user: participants[0])
    create(:positive_comment_ranking, proposal_comment: contribute, user: participants[1])
    create(:negative_comment_ranking, proposal_comment: contribute, user: participants[2])
    create(:neutral_comment_ranking, proposal_comment: contribute, user: participants[3])

    contribute.update!(content: contribute.content)

    #no alerts if the content didn't change
    expect(NotificationProposalCommentUpdate.jobs.size).to eq 0

    contribute.update!(content: Faker::Lorem.paragraph)

    expect(NotificationProposalCommentUpdate.jobs.size).to eq 1
    NotificationProposalCommentUpdate.drain
    expect(Sidekiq::Extensions::DelayedMailer.jobs.size).to eq 3
    Sidekiq::Extensions::DelayedMailer.drain
    deliveries = ActionMailer::Base.deliveries.last(3)

    emails = deliveries.map { |m| m.to[0] }
    receiver_emails = [participants[1],participants[2],participants[3]].map(&:email)
    expect(emails).to match_array(Array.new(3,"discussion+proposal_c_#{proposal.id}@airesis.it"))
    expect(deliveries.map { |m| m.bcc[0] }).to match_array receiver_emails

    expect(Alert.count).to eq 3
    expect(Alert.last(3).map { |a| a.user }).to match_array [participants[1],participants[2],participants[3]]
  end
end
