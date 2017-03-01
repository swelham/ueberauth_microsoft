defmodule UeberauthMicrosoft do
  @moduledoc false

  def default_http_opts, do: [hackney: [ssl_options: [versions: [:'tlsv1.2']]]]
end
