defmodule RemoteIpRewriter do
  import Plug.Conn, only: [get_req_header: 2]
  @behaviour Plug

  @xff_header "x-forwarded-for"

  def init(opts) do
    trust_local_proxies = Keyword.get(opts, :trust_local_proxies, true)
    trusted_proxies = Keyword.get(opts, :trusted_proxies, [])

    {trust_local_proxies, trusted_proxies}
  end

  def call(conn, {trust_local_proxies, trusted_proxies}) do
    if trust_ip?(conn.remote_ip, trust_local_proxies, trusted_proxies) do
      conn |> get_req_header(@xff_header) |> rewrite_remote_ip(conn, trust_local_proxies, trusted_proxies)
    else
      conn
    end
  end

  defp rewrite_remote_ip([], conn, _, _) do
    conn
  end

  defp rewrite_remote_ip([header | _], conn, trust_local_proxies, trusted_proxies) do
    case ips_from(header) |> parse_addresses(trust_local_proxies, trusted_proxies) do
      ip when is_tuple(ip) ->
        %{conn | remote_ip: ip}
      nil ->
        conn
    end
  end

  # Header contains comma separated list of ips. Only the rightmost ip can be
  # trusted so the list of ips is reversed
  defp ips_from(header) do
    header
    |> String.split(",")
    |> Enum.reverse
  end

  defp parse_addresses([], _, _), do: nil

  defp parse_addresses([address | rest], trust_local_proxies, trusted_proxies) do
    case address |> String.strip |> to_char_list |> :inet.parse_address do
      {:ok, ip} ->
        if trust_ip?(ip, trust_local_proxies, trusted_proxies) do
          parse_addresses(rest, trust_local_proxies, trusted_proxies) 
        else
          ip
        end
      _ ->
        nil
    end
  end
  
  defp trust_ip?(remote_ip, trust_local_proxies, trusted_proxies) do
    (trust_local_proxies and private_network?(remote_ip)) or remote_ip in trusted_proxies
  end

  defp private_network?({127, 0, 0, 1}), do: true
  defp private_network?({10, _, _, _}), do: true
  defp private_network?({172, octet, _, _}) when octet >= 16 and octet <= 31, do: true
  defp private_network?({192, 168, _, _}), do: true
  defp private_network?({0, 0, 0, 0, 0, 0, 0, 1}), do: true
  defp private_network?({digit, _, _, _, _, _, _, _}) when digit >= 0xFC00 and digit <= 0xFDFF, do: true
  defp private_network?(_), do: false

end
