class CreateShares < ActiveRecord::Migration[6.1]
  def change
    create_table :shares, id: :uuid do |t|
      t.references :role, type: :uuid, null: false
      t.references :customer, type: :uuid, null: false
      t.string :sharee, null: false
      t.timestamps
    end
  end
end
