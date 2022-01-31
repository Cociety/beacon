module SharedRoles
  extend ActiveSupport::Concern

  included do
    before_action do
      @shared_role_ids = read_shared_role_ids
      shared_role_id_from_params = share&.role&.id
      @shared_role_ids.push(shared_role_id_from_params).uniq! if shared_role_id_from_params
    end

    def process_shared_roles
      return unless @shared_role_ids.any?

      if customer_signed_in?
        add_roles @shared_role_ids
        delete_shared_role_ids
        redirect_to request.path, params: params.except(:share)
      else
        save_shared_role_ids @shared_role_ids
        redirect_to sign_in_url
      end
    end
  end

  def add_roles(role_ids)
    role_ids = [role_ids].flatten
    roles = Role.where(id: role_ids)
    roles.each do |role|
      Current.customer.add_role role.name, role.resource
    end
  end

  def share
    Share.find_by(id: share_param)
  end

  def share_param
    params[:share]
  end

  def read_shared_role_ids
    JSON.parse(cookies.encrypted[:shared_role_ids] || [].to_json)
  end

  def save_shared_role_ids(role_ids)
    cookies.encrypted[:shared_role_ids] = role_ids.to_json
  end

  def delete_shared_role_ids
    cookies.delete(:shared_role_ids)
  end
end
