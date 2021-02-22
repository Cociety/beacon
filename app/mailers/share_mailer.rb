class ShareMailer < ApplicationMailer
  before_action -> { @share = params[:share] }

  def tree_shared
    @customer = Customer.find_by(email: @share.sharee)
    @url = tree_url @share.resource, params: { share: @share.id }
    mail(to: @share.sharee, subject: "#{@share.sharer.name} shared a Beacon Tree with you")
  end
end
