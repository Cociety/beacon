class CreateApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_keys, id: :string do |t|
      t.binary :key
      t.references :customer, type: :uuid, null: false

      t.timestamps
    end
  end
end
