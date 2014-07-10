class AddFullAddressToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :full_address, :string
  end
end
