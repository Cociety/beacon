class Slack::ChatUnfurlJob < Slack::ApiJob
  def perform(channel, ts, links)
    @client.chat_unfurl channel: channel, ts: ts, unfurls: unfurls(links)
  end

  def unfurls(links)
    links.to_h { |l| [l, unfurl(l)] }.to_json
  end

  def unfurl(link)
    {
      blocks: [
        {
          type: "section",
          text: {
              type: "mrkdwn",
              text: "Take a look at this carafe, just another cousin of glass"
          },
          accessory: {
              type: "image",
              image_url: "https://gentle-buttons.com/img/carafe-filled-with-red-wine.png",
              alt_text: "Stein's wine carafe"
          }
      }]
    }
  end
end
