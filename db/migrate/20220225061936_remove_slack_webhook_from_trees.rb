class RemoveSlackWebhookFromTrees < ActiveRecord::Migration[7.0]
  def change
    remove_column :trees, :slack_webhook_url, :string
  end
end
