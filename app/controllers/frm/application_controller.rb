require 'cancan'

class Frm::ApplicationController < ApplicationController
  layout 'groups'

  before_filter :load_group

  protected
  def load_group
    super
    if @group.disable_forums
      head :forbidden
    end
  end

end
