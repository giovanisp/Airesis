class AddMissingForeignKey < ActiveRecord::Migration
  def up

    Group.all(conditions: "participation_role_id != 1").each do |group|
      group.group_participations.each do |participation|
        if participation.participation_role_id == 1
          participation.update_attribute(:participation_role_id,group.participation_role_id)
        end
      end
    end

    MeetingParticipation.where("meeting_id not in (#{Meeting.select(:id).to_sql})").destroy_all
    ActionAbilitation.where("participation_role_id not in (#{ParticipationRole.select(:id).to_sql})").destroy_all
    GroupAffinity.where("group_id not in (#{Group.select(:id).to_sql})").destroy_all
    GroupParticipationRequest.where("group_id not in (#{Group.select(:id).to_sql})").destroy_all
    GroupParticipation.where("group_id not in (#{Group.select(:id).to_sql})").destroy_all
    ProposalVote.where("proposal_id not in (#{Proposal.select(:id).to_sql})").destroy_all

    add_foreign_key :meeting_participations, :users
    add_foreign_key :meeting_participations, :meetings
    add_foreign_key :meetings, :places
    add_foreign_key :meetings, :events
    add_foreign_key :notifications, :notification_types
    add_foreign_key :participation_roles, :participation_roles, {column: :parent_participation_role_id}
    add_foreign_key :participation_roles, :groups
    add_foreign_key :post_publishings, :groups
    add_foreign_key :post_publishings, :blog_posts
    add_foreign_key :proposal_borders, :interest_borders
    add_foreign_key :proposal_borders, :proposals
    add_foreign_key :proposal_categories, :proposal_categories, {column: :parent_proposal_category_id}
    add_foreign_key :proposal_comment_rankings, :proposal_comments
    add_foreign_key :proposal_comment_rankings, :users
    add_foreign_key :proposal_comment_rankings, :ranking_types
    add_foreign_key :proposal_comments, :users
    add_foreign_key :proposal_comments, :proposals
    add_foreign_key :proposal_comments, :users, {culumn: :deleted_user_id, name: 'proposal_comments_deleted_user_id_fk'}
    add_foreign_key :proposal_presentations, :proposals
    add_foreign_key :proposal_presentations, :users
    add_foreign_key :proposal_rankings, :proposals
    add_foreign_key :proposal_rankings, :users
    add_foreign_key :proposal_supports, :proposals
    add_foreign_key :proposal_supports, :groups
    add_foreign_key :proposal_votes, :proposals
    add_foreign_key :proposals, :proposal_states
    add_foreign_key :proposals, :proposal_categories
    add_foreign_key :proposals, :events, {column: :vote_period_id}
    add_foreign_key :users, :user_types
    add_foreign_key :users, :images
    add_foreign_key :user_votes, :users
    add_foreign_key :user_follows, :users, {column: :follower_id}
    add_foreign_key :user_follows, :users, {column: :followed_id}
    add_foreign_key :user_borders, :users
    add_foreign_key :user_borders, :interest_borders
    add_foreign_key :user_alerts, :notifications
    add_foreign_key :user_alerts, :users
    add_foreign_key :tutorial_progresses, :users
    add_foreign_key :tutorial_progresses, :steps
    add_foreign_key :tutorial_assignees, :users
    add_foreign_key :tutorial_assignees, :tutorials
    add_foreign_key :action_abilitations, :group_actions
    add_foreign_key :action_abilitations, :groups
    add_foreign_key :action_abilitations, :participation_roles
    add_foreign_key :authentications, :users
    add_foreign_key :blocked_alerts, :notification_types
    add_foreign_key :blocked_alerts, :users
    add_foreign_key :blocked_emails, :notification_types
    add_foreign_key :blocked_emails, :users
    add_foreign_key :blog_comments, :blog_comments, {column: :parent_blog_comment_id}
    add_foreign_key :blog_comments, :blog_posts
    add_foreign_key :blog_comments, :users
    add_foreign_key :blog_post_tags, :blog_posts
    add_foreign_key :blog_posts, :blogs
    add_foreign_key :blog_posts, :users
    add_foreign_key :blog_tags, :blogs
    add_foreign_key :blogs, :users
    add_foreign_key :events, :event_types
    add_foreign_key :group_affinities, :groups
    add_foreign_key :group_affinities, :users
    add_foreign_key :group_participation_requests, :users
    add_foreign_key :group_participation_requests, :groups
    add_foreign_key :group_participation_requests, :group_participation_request_statuses, name: 'parent_fk'
    add_foreign_key :group_participations, :users
    add_foreign_key :group_participations, :groups
    add_foreign_key :group_participations, :participation_roles
    add_foreign_key :groups, :interest_borders
    drop_table :blog_entries if self.table_exists?("blog_entries")
    drop_table :provas if self.table_exists?("provas")
  end

  def down
  end

  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end
end

