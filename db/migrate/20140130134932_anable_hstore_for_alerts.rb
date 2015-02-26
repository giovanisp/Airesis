class AnableHstoreForAlerts < ActiveRecord::Migration
  def up
    add_column :user_alerts, :properties, :hstore
    add_column :notifications, :properties, :hstore
    Notification.all.each do |notification|
      data = {}
      notification.notification_data.each do |d|
          name = d.name
          value = d.value
          data[name] = value
        end
      notification.properties = data
      notification.save!
    end
  end

  def down
    remove_column :user_alerts, :properties
    remove_column :notifications, :properties
  end
end
