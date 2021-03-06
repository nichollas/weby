class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.integer  :site_id
      t.integer  :viewable_id
      t.string   :viewable_type
      t.integer  :user_id
      t.string   :request_path
      t.string   :user_agent
      t.string   :session_hash
      t.string   :ip_address
      t.string   :referer
      t.string   :query_string

      t.timestamps
    end
    
    add_index :views, :site_id
    add_index :views, :user_id
    
    add_foreign_key :views, :sites
    add_foreign_key :views, :users
  end
end
