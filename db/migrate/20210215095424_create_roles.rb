class CreateRoles < ActiveRecord::Migration[6.1]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name
      t.references :resource, polymorphic: true, type: :uuid

      t.timestamps
    end

    create_table :model_roles, id: false do |t|
      t.references :model, polymorphic: true, type: :uuid
      t.references :role, type: :uuid
    end

    add_index :roles, %i[name resource_type resource_id], unique: true
    add_index :model_roles, %i[model_type model_id role_id], unique: true
  end
end
