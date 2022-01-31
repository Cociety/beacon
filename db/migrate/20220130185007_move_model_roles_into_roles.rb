class MoveModelRolesIntoRoles < ActiveRecord::Migration[7.0]
  def change
    add_reference :roles, :customer, **{ type: :uuid, null: true }

    # Delete all ModelRoles where the role doesn't exist
    ModelRole.left_joins(:role)
             .where({role: {id: nil}})
             .each &:destroy

    ModelRole.all.each do |model_role|
      model_role.role.update_attribute(:customer_id, model_role.model_id)
    end

    change_column :roles, :customer_id, :uuid, **{null:false}
    add_index :roles, %i[customer_id name resource_type resource_id], unique: true, name: :index_roles_on_customer_and_name_and_resource
    remove_index :roles, %i[name resource_type resource_id]

    drop_table :model_roles
  end
end
