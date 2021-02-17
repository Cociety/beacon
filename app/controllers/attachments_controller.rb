class AttachmentsController < ApplicationController
  def destroy
    @attachment = ActiveStorage::Attachment.find params[:id]
    authorize @attachment.record
    @attachment.purge
  end
end
