#encoding: utf-8
module Frm
  class Forum < Frm::FrmTable
    include Frm::Concerns::Viewable, ::Concerns::Taggable

    extend FriendlyId
    friendly_id :name, use: :scoped, scope: :group

    belongs_to :category, class_name: 'Frm::Category'

    belongs_to :group, class_name: '::Group', foreign_key: 'group_id'

    has_many :topics, class_name: 'Frm::Topic', dependent: :destroy
    has_many :posts, class_name: 'Frm::Post', through: :topics, dependent: :destroy
    has_many :moderators, through: :moderator_groups, source: :frm_group, class_name: 'Frm::Group'
    has_many :moderator_groups

    has_many :forum_tags, dependent: :destroy, foreign_key: 'frm_forum_id'
    has_many :tags, through: :forum_tags, class_name: 'Tag'

    validates :category, :name, :description, presence: true

    validate :visibility

    alias_attribute :title, :name

    def last_post_for(forem_user)
      if forem_user && (forem_user.forem_admin?(group) || moderator?(forem_user))
        posts.last
      else
        last_visible_post(forem_user)
      end
    end

    def last_visible_post(forem_user)
      posts.approved_or_pending_review_for(forem_user).last
    end

    def moderator?(user)
      user && (user.frm_group_ids & moderator_ids).any?
    end

    def to_s
      name
    end


    protected

    def visibility
      self.errors.add(:visible_outside, "Un forum non può essere visibile all''esterno se la sezione in cui è contenuto non è visibile") if (self.visible_outside && !self.category.visible_outside)
    end
  end
end
