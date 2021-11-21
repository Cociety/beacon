class Trees::SharesController < ApplicationController
  before_action :set_tree

  def new
    @share = Share.new
  end

  def create
    @share = Share.new share_params
    return unless @share.save

    flash[:notice] = t '.shared', with: @share.sharee
    redirect_to @share.role.resource
  end

  private

  def set_tree
    @tree = authorize Tree.find(params[:tree_id]), :share?
  end

  def share_params
    params.require(:share)
          .permit(:sharee)
          .merge(
            role:     Role.find_or_create_by!(name: role_name, resource: @tree),
            customer: Current.customer
          )
  end

  def role_name
    read_only? ? :reader : :writer
  end

  def read_only?
    !!ActiveModel::Type::Boolean.new.cast(params.require(:share)[:read_only]&.downcase)
  end
end
