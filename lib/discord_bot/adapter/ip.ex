defmodule DiscordBot.Adapter.Ip do
  @api_endpoint "https://inet-ip.info/ip"

  def get_global_ip() do
    case Req.get!(@api_endpoint) do
      %{status: 200, body: body} -> body
      _ -> "Failed to get IP address"
    end
  end
end
