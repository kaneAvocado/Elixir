defmodule ProgressTreeWeb.GenealogyLive.Show do
  use ProgressTreeWeb, :live_view

  alias ProgressTree.Knowledge
  alias ProgressTree.Knowledge.Search

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    gene = Knowledge.get_gene_with_author!(id)

    {:ok,
     socket
     |> assign(:page_title, gene.title)
     |> assign(:gene, gene)
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:selected_node, nil)}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    {:noreply,
     socket
     |> assign(:search_query, query)
     |> assign(:search_results, Search.search_genes(query))}
  end

  @impl true
  def handle_event("select_node", %{"id" => id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/genealogy/#{id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-[calc(100vh-4rem)] bg-gray-50 -mx-4 sm:-mx-6 lg:-mx-8">
      <aside class="w-96 bg-white border-r border-gray-200 flex flex-col shrink-0">
        <div class="p-5 border-b bg-indigo-50">
          <.gene_card gene={@gene} />
        </div>

        <div class="p-4 border-b">
          <form phx-change="search">
            <.input
              type="text"
              name="query"
              value={@search_query}
              placeholder="Поиск..."
              phx-debounce="300"
            />
          </form>
        </div>

        <div class="flex-1 overflow-y-auto p-3">
          <%= for result <- @search_results do %>
            <button
              type="button"
              phx-click="select_node"
              phx-value-id={result.id}
              class="w-full text-left p-3 mb-2 rounded-lg hover:bg-indigo-50 transition"
            >
              <p class="text-sm font-semibold truncate"><%= result.title %></p>
              <p class="text-xs text-gray-500"><%= result.inventory_number %></p>
            </button>
          <% end %>
        </div>
      </aside>

      <main class="flex-1 bg-gray-100 flex items-center justify-center">
        <p class="text-gray-400 text-sm">Область графа</p>
      </main>
    </div>
    """
  end
end
