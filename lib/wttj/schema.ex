defmodule Wttj.Schema do
  use Absinthe.Schema
  import_types Wttj.Types.LinkTypes

  # def plugins do
    # [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  # end

  alias Wttj.Resolvers

  query do

    @desc "Get all links"
    field :links, list_of(:link) do
      resolve &Resolvers.Links.list_links/3
    end
  end



end
