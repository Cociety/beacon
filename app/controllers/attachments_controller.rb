class AttachmentsController < ApplicationController
  def destroy
    @attachment = ActiveStorage::Attachment.find params[:id]
    authorize @attachment.record
    @attachment.purge
    redirect_to @attachment.record
  end
end
