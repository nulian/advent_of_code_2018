defmodule Assign8_1 do
  @moduledoc false

  defmodule Node do
    defstruct node_count: 0, metadata_entry_count: 0, child_nodes: [], metadata_entries: []

    def create_node([node_count, metadata_count | rest]) do
      node_count = String.to_integer(node_count)
      metadata_count = String.to_integer(metadata_count)
      {remaining_data, nodes} = node_loop(node_count, {rest, []})

      {metadata, rest_data} = read_metadata(remaining_data, metadata_count)

      {rest_data, %Node{node_count: node_count, metadata_entry_count: metadata_count, child_nodes: nodes, metadata_entries: metadata}}
    end

    def node_loop(0, acc), do: acc
    def node_loop(current, {data, acc}) do
        {remaining_data, node} = create_node(data)
       node_loop(current - 1, {remaining_data, [node | acc]})
    end

    def read_metadata(data, count) do
      metadata = Enum.take(data, count) |> Enum.map(& String.to_integer(&1))
      rest_data = Enum.drop(data, count)
      {metadata, rest_data}
    end

    def collect_all_metadata_entries(%Node{child_nodes: child_nodes, metadata_entries: metadata_entries}) do
      [Enum.map(child_nodes, &collect_all_metadata_entries(&1))| metadata_entries]
    end
  end


  def assignment do
    {_, nodes} = "data/assign8.data"
                 |> File.read!()
                 |> String.split(" ")
                 |> Node.create_node()
    nodes
    |> Node.collect_all_metadata_entries()
    |> List.flatten()
    |> Enum.sum()
  end
end
