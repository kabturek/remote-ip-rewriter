# TrustedProxyRewriter

An Elixir plug to rewrite the value of **remote_ip** key of [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html) struct if the request comes from a trusted proxy.
It expects the header to contain only one ip address.

## Installation

  1. Add the plug to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:trusted_proxy_rewriter, "~> 0.1.0"}
      ]
    end
    ```

  2. If you are using [Phoenix Framework](http://www.phoenixframework.org/) then put the plug in your application's endpoint `lib\your_app\endpoint.ex`:

    ```elixir
    defmodule YourApp.Endpoint do
      ...
      plug TrustedProxyRewriter, proxies: ["192.168.0.1/32"], header: "x-real-ip"
      ...
      plug YourApp.Router
    end
    ```

  3. Configuration:

    :proxies - list of trusted proxies
    :header - name of the header with ip address

    By default no proxy is trusted and the default header is x-real-ip

## Changelog

### 0.1.0
Started using the InetCidr library so the proxy list has to be in full CIDR notation

Based on https://github.com/krzysztofmo/remote-ip-rewriter
