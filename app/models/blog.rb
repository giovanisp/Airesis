class Blog < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  include BlogKitModelHelper

  belongs_to :user
  has_many :blog_posts, dependent: :destroy
  has_many :comments, through: :blog_posts, source: :blog_comments
  
  has_many :blog_tags, dependent: :destroy
  has_many :tags, through: :blog_tags, class_name: 'Tag'

  def last_post
    self.blog_posts.order(created_at: :desc).first
  end

  searchable do
    text :title, boost: 2
    time :created_at
    time :last_post_created_at do
      self.last_post.try(:created_at)
    end
    text :fullname do
      self.user.fullname
    end
  end

  def self.look(params)
    search = params[:search]
    params[:minimum] = params[:and] ? nil : 1

    tag = params[:tag]

    page = params[:page] || 1
    limite = params[:limit] || 30

    if tag
      Blog.joins(blog_posts: :tags).where(['tags.text = ?', tag]).uniq.page(page).per(limite)
    else
      Blog.search do
        fulltext search, minimum_match: params[:minimum] if search
        order_by :score, :desc
        order_by :last_post_created_at, :desc
        order_by :created_at, :desc

        paginate page: page, per_page: limite

      end.results
    end
  end
end
