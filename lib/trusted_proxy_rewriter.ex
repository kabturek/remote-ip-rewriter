defmodule TrustedProxyRewriter do
  import Plug.Conn, only: [get_req_header: 2]
  @behaviour Plug

  @xff_header "x-real-ip"

  def init(opts) do
    trusted_proxies = Keyword.get(opts, :proxies, []) |> Enum.map(&InetCidr.parse/1)
    header_name = Keyword.get(opts, :header_name, @xff_header)

    {header_name, trusted_proxies}
  end

  def call(conn, {header_name, trusted_proxies}) do
    if trust_ip?(conn.remote_ip, trusted_proxies) do
      conn |> get_req_header(header_name) |> rewrite_remote_ip(conn)
    else
      conn
    end
  end

  defp trust_ip?(remote_ip, trusted_proxies) do
    Enum.any?(trusted_proxies, &(InetCidr.contains?(&1, remote_ip)))
  end

  defp rewrite_remote_ip([], conn) do
    conn
  end

  #Header contains only on ip
  defp rewrite_remote_ip([header | _], conn) do
    case parse_addresses(header) do
      ip when is_tuple(ip) ->
        %{conn | remote_ip: ip}
      nil ->
        conn
    end
  end

  defp parse_addresses(nil), do: nil

  defp parse_addresses(address) do
    case address |> String.trim |> to_charlist |> :inet.parse_address do
      {:ok, ip} -> ip
      _ -> nil
    end
  end
end
