class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :business_id
      t.string :name
      t.float :stars
      t.integer :review_count
      t.string :city
      t.string :state
      t.integer :num_prosocial
      t.integer :num_risktaker
      t.integer :num_anxious
      t.integer :num_passive
      t.integer :num_perfectionist
      t.integer :num_critical
      t.integer :num_conscientious
      t.integer :num_openminded
      t.integer :num_intuitive
      t.integer :num_liberal

      t.timestamps
    end
  end
end
