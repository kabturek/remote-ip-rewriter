defmodule RemoteIpRewriterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  def remote_ip(conn, opts \\ []) do
    RemoteIpRewriter.call(conn, RemoteIpRewriter.init(opts))
  end

  test "doesnt trust proxies not in truested_proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({10, 1, 1, 10}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(trusted_proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {10, 1, 1, 10}
  end

  test "trusts proxy defined in trusted_proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(trusted_proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {1, 2, 3, 4}
  end

  test "trusts multiple proxies defined in trusted_proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(trusted_proxies: [{45, 1, 1, 4}, {5, 6, 7, 8}])
    assert conn.remote_ip == {1, 2, 3, 4}
  end

  test "returns remote_ip if no header present" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> remote_ip(trusted_proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {45, 1, 1, 4}
  end

  defp put_xff_header(conn, value) do
    put_req_header(conn, "x-real-ip", value)
  end

  def set_remote_ip(conn, value) do
    %{conn | remote_ip: value}
  end
end
