class NotificationType < ActiveRecord::Base
  NEW_CONTRIBUTES = 1
  TEXT_UPDATE = 2
  NEW_PUBLIC_PROPOSALS = 3
  CHANGE_STATUS = 4
  NEW_CONTRIBUTES_MINE = 5
  CHANGE_STATUS_MINE = 6
  NEW_POST_GROUP = 9
  NEW_PROPOSALS = 10
  NEW_PARTICIPATION_REQUEST = 12
  NEW_PUBLIC_EVENTS = 13
  NEW_EVENTS = 14
  NEW_VALUTATION_MINE = 20
  NEW_VALUTATION = 21
  AVAILABLE_AUTHOR = 22
  AUTHOR_ACCEPTED = 23
  NEW_AUTHORS = 24
  UNINTEGRATED_CONTRIBUTE = 25
  NEW_BLOG_COMMENT = 26
  NEW_COMMENTS_MINE = 27
  NEW_COMMENTS = 28
  CONTRIBUTE_UPDATE = 29
  PHASE_ENDING = 30

  NEW_FORUM_TOPIC = 'new_forum_topic'

  belongs_to :notification_category
  has_many :blocked_alerts
  has_many :notifications
  has_many :blockers, through: :blocked_alerts, class_name: 'User', source: :user

  def description
    I18n.t("db.#{self.class.class_name.tableize}.#{name}.description")
  end

  # TODO
  def destroyable
    []
  end
end
