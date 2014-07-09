class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :business_id
      t.string :name
      t.float :stars
      t.integer :review_count
      t.string :city
      t.string :state
      t.string :dominant_type
      t.integer :dominant_value
      t.integer :num_introverted
      t.integer :num_extroverted
    end
  end
end
