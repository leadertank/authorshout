module ShareHelper
  def social_share_links(url:, text:)
    encoded_url = ERB::Util.url_encode(url)
    encoded_text = ERB::Util.url_encode(text)

    {
      "X" => "https://twitter.com/intent/tweet?url=#{encoded_url}&text=#{encoded_text}",
      "Pinterest" => "https://pinterest.com/pin/create/button/?url=#{encoded_url}&description=#{encoded_text}",
      "Bluesky" => "https://bsky.app/intent/compose?text=#{encoded_text}%20#{encoded_url}",
      "Threads" => "https://www.threads.net/intent/post?text=#{encoded_text}%20#{encoded_url}",
      "Reddit" => "https://www.reddit.com/submit?url=#{encoded_url}&title=#{encoded_text}"
    }
  end
end
