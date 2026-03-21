defmodule ProgressTreeWeb.GeneCard do
  use Phoenix.Component

  attr :gene, :map, required: true
  attr :compact, :boolean, default: false

  def gene_card(assigns) do
    ~H"""
    <div class={[
      "rounded-lg border border-gray-200 bg-white",
      @compact && "p-3",
      !@compact && "p-5"
    ]}>
      <span class="text-xs font-mono text-indigo-600 bg-indigo-100 px-2 py-1 rounded">
        <%= @gene.inventory_number %>
      </span>
      <h2 class={["font-bold text-gray-900 mt-2", @compact && "text-base", !@compact && "text-xl"]}>
        <%= @gene.title %>
      </h2>
      <div class="flex gap-3 mt-2 text-sm text-gray-600">
        <span><%= @gene.doc_type %></span>
        <span>•</span>
        <span><%= @gene.department %></span>
        <span>•</span>
        <span><%= @gene.year %></span>
      </div>
      <div class="mt-2 flex items-center gap-2">
        <span class={[
          "inline-block w-2 h-2 rounded-full",
          @gene.status == "актуально" && "bg-green-500",
          @gene.status != "актуально" && "bg-yellow-500"
        ]} />
        <span class="text-sm capitalize"><%= @gene.status %></span>
      </div>
      <%= if @gene.author do %>
        <p class="text-sm text-gray-500 mt-2">Автор: <%= @gene.author.full_name %></p>
      <% end %>
    </div>
    """
  end
end
