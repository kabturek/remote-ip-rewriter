defmodule TrustedProxyRewriterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  def remote_ip(conn, opts \\ []) do
    TrustedProxyRewriter.call(conn, TrustedProxyRewriter.init(opts))
  end

  test "doesnt trust proxies not in proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({10, 1, 1, 10}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {10, 1, 1, 10}
  end

  test "trusts proxy defined in proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {1, 2, 3, 4}
  end

  test "trusts multiple proxies defined in proxies" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> put_xff_header("1.2.3.4") 
           |> remote_ip(proxies: [{45, 1, 1, 4}, {5, 6, 7, 8}])
    assert conn.remote_ip == {1, 2, 3, 4}
  end

  test "returns remote_ip if no header present" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> remote_ip(proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {45, 1, 1, 4}
  end
  
  test "uses the specified header_name" do
    conn = conn(:get, "/") 
           |> set_remote_ip({45, 1, 1, 4}) 
           |> put_req_header("x-specific-header", "5.6.7.8")
           |> remote_ip(header_name: "x-specific-header", proxies: [{45, 1, 1, 4}])
    assert conn.remote_ip == {5, 6, 7, 8}
  end

  defp put_xff_header(conn, value) do
    put_req_header(conn, "x-real-ip", value)
  end

  def set_remote_ip(conn, value) do
    %{conn | remote_ip: value}
  end
end
