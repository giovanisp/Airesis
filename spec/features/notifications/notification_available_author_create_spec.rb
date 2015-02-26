require 'spec_helper'
require 'requests_helper'
require "cancan/matchers"

describe 'notifications for new authors available', type: :feature do


  it "sends correctly an email to authors of the proposal" do
    user = create(:user)
    proposal = create(:public_proposal, quorum: BestQuorum.public.first, current_user_id: user.id)
    user2 = create(:user)
    available_author = create(:available_author, proposal: proposal, user: user2)
    expect(NotificationAvailableAuthorCreate.jobs.size).to eq 1
    NotificationAvailableAuthorCreate.drain
    expect(Sidekiq::Extensions::DelayedMailer.jobs.size).to eq 1
    Sidekiq::Extensions::DelayedMailer.drain
    last_delivery = ActionMailer::Base.deliveries.last
    expect(last_delivery.to[0]).to eq user.email
    expect(Alert.last.user).to eq user
    expect(Alert.last.notification_type.id).to eq NotificationType::AVAILABLE_AUTHOR
  end

  it "sends an email to all authors of the proposal" do
    user = create(:user)
    user2 = create(:user)
    user3 = create(:user)
    authors= [user, user2, user3]
    proposal = create(:public_proposal, quorum: BestQuorum.public.first, current_user_id: user.id)
    proposal.users << user2
    proposal.users << user3
    proposal.save
    user4 = create(:user)
    available_author = create(:available_author, proposal: proposal, user: user4)
    expect(NotificationAvailableAuthorCreate.jobs.size).to eq 1
    NotificationAvailableAuthorCreate.drain
    expect(Sidekiq::Extensions::DelayedMailer.jobs.size).to eq authors.size
    Sidekiq::Extensions::DelayedMailer.drain
    last_deliveries = ActionMailer::Base.deliveries.last(authors.size)
    emails = last_deliveries.map { |m| m.to[0] }
    receiver_emails = authors.map(&:email)
    expect(emails).to match_array receiver_emails
    expect(Alert.last(authors.size).map { |a| a.user }).to match_array authors
    expect(Alert.last.notification_type.id).to eq NotificationType::AVAILABLE_AUTHOR
  end
end
