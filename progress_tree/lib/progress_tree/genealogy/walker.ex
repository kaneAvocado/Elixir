defmodule ProgressTree.Genealogy.Walker do
  @moduledoc """
  Coordinates async graph walks (bidirectional BFS for common ancestors).
  """

  use GenServer
  import Ecto.Query
  alias ProgressTree.Repo
  alias ProgressTree.Knowledge.TechRelation

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{}, Keyword.put_new(opts, :name, __MODULE__))
  end

  @doc "Starts async search; returns `{:async, ref}`."
  def find_common_root(gene_a_id, gene_b_id) do
    GenServer.call(__MODULE__, {:find_common_root, gene_a_id, gene_b_id})
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:find_common_root, gene_a, gene_b}, _from, state) do
    task =
      Task.Supervisor.async_nolink(ProgressTree.TaskSupervisor, fn ->
        bidirectional_bfs(gene_a, gene_b)
      end)

    {:reply, {:async, task.ref}, state}
  end

  @doc false
  def bidirectional_bfs(source_id, target_id) do
    if source_id == target_id do
      {:ok, %{common_ancestor: source_id, path: [source_id]}}
    else
      do_bidirectional_bfs(source_id, target_id)
    end
  end

  defp do_bidirectional_bfs(source_id, target_id) do
    forward = %{source_id => nil}
    backward = %{target_id => nil}
    qf = :queue.in(source_id, :queue.new())
    qb = :queue.in(target_id, :queue.new())

    bfs_loop(qf, qb, forward, backward, :forward)
  end

  defp bfs_loop(qf, qb, forward, backward, turn) do
    cond do
      :queue.len(qf) == 0 and :queue.len(qb) == 0 ->
        {:error, :no_common_ancestor}

      turn == :forward and :queue.len(qf) > 0 ->
        {current, qf} = :queue.out(qf)

        case meet?(current, backward) do
          {:ok, meeting} -> build_result(meeting, forward, backward)
          :no -> bfs_expand(current, qf, forward, qb, backward, :backward)
        end

      true ->
        {current, qb} = :queue.out(qb)

        case meet?(current, forward) do
          {:ok, meeting} -> build_result(meeting, forward, backward)
          :no -> bfs_expand(current, qb, backward, qf, forward, :forward)
        end
    end
  end

  defp meet?(node, other_map) do
    if Map.has_key?(other_map, node), do: {:ok, node}, else: :no
  end

  defp bfs_expand(current, q, this_map, other_q, other_map, next_turn) do
    neighbors = neighbor_ids(current)

    {q, this_map} =
      Enum.reduce(neighbors, {q, this_map}, fn nid, {q_acc, map_acc} ->
        if Map.has_key?(map_acc, nid) do
          {q_acc, map_acc}
        else
          {:queue.in(nid, q_acc), Map.put(map_acc, nid, current)}
        end
      end)

    bfs_loop(q, other_q, this_map, other_map, next_turn)
  end

  defp neighbor_ids(gene_id) do
    parents =
      from(r in TechRelation, where: r.child_id == ^gene_id, select: r.parent_id)
      |> Repo.all()

    children =
      from(r in TechRelation, where: r.parent_id == ^gene_id, select: r.child_id)
      |> Repo.all()

    parents ++ children
  end

  defp build_result(meeting, forward, backward) do
    path_to_source = trace_path(meeting, forward)
    path_to_target = trace_path(meeting, backward)
    {:ok, %{common_ancestor: meeting, path: Enum.reverse(path_to_source) ++ tl(path_to_target)}}
  end

  defp trace_path(node, parent_map) do
    Stream.iterate(node, &Map.get(parent_map, &1))
    |> Stream.take_while(& &1)
    |> Enum.to_list()
  end
end
