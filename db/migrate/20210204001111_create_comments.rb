class CreateComments < ActiveRecord::Migration[6.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.string :text, null: false
      t.references :customer, type: :uuid, null: false
      t.references :commentable, polymorphic: true, type: :uuid

      t.timestamps
    end
  end
end
