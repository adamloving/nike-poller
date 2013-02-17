class AddReportTimeToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_report_time, :datetime
    add_column :users, :nike_access_token, :string
  end
end
