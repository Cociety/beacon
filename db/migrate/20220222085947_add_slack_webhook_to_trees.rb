class AddSlackWebhookToTrees < ActiveRecord::Migration[7.0]
  def change
    add_column :trees, :slack_webhook_url, :string
  end
end
