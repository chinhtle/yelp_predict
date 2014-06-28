class AddIndexToBusinessesBusinessId < ActiveRecord::Migration
  def change
    add_index :businesses, :business_id, unique: true
  end
end
