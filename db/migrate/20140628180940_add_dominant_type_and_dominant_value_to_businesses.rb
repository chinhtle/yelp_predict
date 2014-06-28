class AddDominantTypeAndDominantValueToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :dominant_type, :string
    add_column :businesses, :dominant_value, :integer
  end
end
