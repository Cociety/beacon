# Preview all emails at http://localhost:3001/rails/mailers/share_mailer
class ShareMailerPreview < ActionMailer::Preview
  def tree_shared
    ShareMailer.with(share: Share.first).tree_shared
  end
end
