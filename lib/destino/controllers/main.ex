defmodule Destino.Controllers.Main do
  use Sugar.Controller

  def index(conn, args) do
    if length(args) == 0 do
      render conn
    else
      redirect conn, gem_page(args[:gem])
    end
  end

  # Returns github page url or rubygems gem page url
  # TODO: check if github page really exists
  defp gem_page(gem) do
    api_url = "https://rubygems.org/api/v1/gems/#{gem}.json"
    response = HTTPoison.get! api_url

    if response.status_code == 404 do
      # redirect to rubygems 404 page
      "https://rubygems.org/gems/#{gem}"
    else
      json = JSX.decode! response.body
      repo = get_repo_name(json["homepage_uri"]) || get_repo_name(json["source_code_uri"])

      if is_nil(repo), do: json["project_uri"], else: "https://github.com/#{repo}"
    end
  end

  # Extracts full repo name from github url
  defp get_repo_name(url) do
    unless is_nil(url) do
      Regex.scan(~r/\Ahttps?:\/\/github.com\/(.+\/.+)/, url)
      |> List.flatten
      |> List.last
    end
  end
end
