class OutsideVisible < ActiveRecord::Migration
  def up
    add_column :proposals, :visible_outside, :boolean, default: false, null: false
    add_column :groups, :default_visible_outside, :boolean, default: false, null: false
  end

  def down
    remove_column :proposals, :visible_outside
    remove_column :groups, :default_visible_outside
  end
end
