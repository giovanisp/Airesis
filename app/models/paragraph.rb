#encoding: utf-8
class Paragraph < ActiveRecord::Base
  belongs_to :section

  has_many :proposal_comments

  attr_accessor :content_dirty

  validates_length_of :content, within: 1..40000, allow_blank: true

  before_destroy :remove_related_comments

  def remove_related_comments
    self.proposal_comments.update_all(paragraph_id: nil)
  end

  def content_dirty
    @content_dirty ||= self.content
  end

  def content_dirty= val
    @content_dirty = val
  end

  def content=(content)
    ed_content = content ? content.gsub('&nbsp;', ' ').strip.gsub('<br></p>','</p>') : nil
    ed_content='<p></p>' if ed_content.to_s == ''
    write_attribute(:content, ed_content)
  end

end