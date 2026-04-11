defmodule ProgressTreeWeb.GenealogyLive.Show do
  use ProgressTreeWeb, :live_view

  alias ProgressTree.Knowledge
  alias ProgressTree.Knowledge.{Graph, Search, Tree}

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    gene = Knowledge.get_gene_with_author!(id)
    descendants = Tree.get_descendants(gene.id)
    graph_data = Graph.build_graph_json(gene, descendants)

    {:ok,
     socket
     |> assign(:page_title, gene.title)
     |> assign(:gene, gene)
     |> assign(:descendants, descendants)
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:selected_node, nil)
     |> assign(:ancestry_path, [])
     |> assign(:graph_data, graph_data)}
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
              placeholder="Поиск по названию или инв. номеру..."
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
              class="w-full text-left p-3 mb-2 rounded-lg hover:bg-indigo-50 border border-transparent hover:border-indigo-200 transition"
            >
              <p class="text-sm font-semibold text-gray-800 truncate"><%= result.title %></p>
              <p class="text-xs text-gray-500 mt-1">
                <%= result.inventory_number %> • <%= result.department %>
              </p>
            </button>
          <% end %>
        </div>
      </aside>

      <main class="flex-1 relative bg-gray-100">
        <div
          id="genealogy-canvas"
          phx-hook="GenealogyGraph"
          phx-update="ignore"
          data-graph={Jason.encode!(@graph_data)}
          class="w-full h-full min-h-[480px]"
        />

        <div class="absolute bottom-5 left-5 bg-white/95 backdrop-blur rounded-xl shadow-lg p-4 text-xs">
          <h4 class="font-semibold text-gray-700 mb-2">Типы связей</h4>
          <div class="flex items-center gap-2 mb-1">
            <span class="w-6 h-0.5 bg-emerald-500 inline-block"></span>
            <span>Наследование</span>
          </div>
          <div class="flex items-center gap-2 mb-1">
            <span class="w-6 h-0.5 bg-amber-500 inline-block border-dashed border-t-2 border-amber-500"></span>
            <span>Вдохновение</span>
          </div>
          <div class="flex items-center gap-2">
            <span class="w-6 h-0.5 bg-blue-500 inline-block"></span>
            <span>Сборка</span>
          </div>
        </div>
      </main>
    </div>
    """
  end
end
