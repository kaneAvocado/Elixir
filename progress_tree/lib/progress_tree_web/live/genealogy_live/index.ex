defmodule ProgressTreeWeb.GenealogyLive.Index do
  use ProgressTreeWeb, :live_view

  alias ProgressTree.Knowledge
  alias ProgressTree.Knowledge.Search

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Каталог разработок")
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:genes, Knowledge.list_genes())}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    results = Search.search_genes(query)

    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:search_results, results)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto px-4 py-8">
      <.header>
        ProgressTree — каталог технических генов
        <:subtitle>НИИ «Прогресс» — наследование разработок</:subtitle>
      </.header>

      <form phx-change="search" class="mt-6">
        <.input
          type="text"
          name="query"
          value={@search_query}
          placeholder="Поиск по названию или инв. номеру..."
          phx-debounce="300"
        />
      </form>

      <ul class="mt-6 space-y-2">
        <%= for gene <- display_genes(@search_query, @search_results, @genes) do %>
          <li>
            <.link
              navigate={~p"/genealogy/#{gene.id}"}
              class="block p-4 rounded-lg border border-gray-200 hover:border-indigo-300 hover:bg-indigo-50 transition"
            >
              <span class="text-xs font-mono text-indigo-600"><%= gene.inventory_number %></span>
              <p class="font-semibold text-gray-900 mt-1"><%= gene.title %></p>
              <p class="text-sm text-gray-500 mt-1">
                <%= gene.doc_type %> • <%= gene.department %> • <%= gene.year %>
              </p>
            </.link>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  defp display_genes("", _results, genes), do: genes
  defp display_genes(_query, results, _genes), do: results
end
