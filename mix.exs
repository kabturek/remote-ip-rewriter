defmodule TrustedProxyRewriter.Mixfile do
  use Mix.Project

  def project do
    [app: :trusted_proxy_rewriter,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package()]
  end

  def application do
    []
  end

  defp deps do
    [
      {:plug, "~> 1.3.5"},
      {:inet_cidr, "~> 1.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    An Elixir plug to rewrite the value of remote_ip key of Plug.Conn struct if the request comes from a trusted proxy.
    """
  end

  defp package do
    [files: ~w(lib mix.exs README.md LICENSE),
     maintainers: ["Marcin Domański"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/kabturek/trusted-proxy-rewriter"}]
end


end
