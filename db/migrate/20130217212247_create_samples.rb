class CreateSamples < ActiveRecord::Migration
  def up
    create_table :samples do |t|
      t.column :user_id, :integer
      t.column :start_at, :datetime
      t.column :end_at, :datetime
      t.column :steps, :integer
      t.timestamps
    end
  end

  def down
  end
end
