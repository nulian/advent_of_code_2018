defmodule Assign8_2 do
  @moduledoc false

  defmodule Node do
    defstruct node_count: 0, metadata_entry_count: 0, child_nodes: [], metadata_entries: []

    def create_node([node_count, metadata_count | rest]) do
      node_count = String.to_integer(node_count)
      metadata_count = String.to_integer(metadata_count)
      {remaining_data, nodes} = node_loop(node_count, {rest, []})

      {metadata, rest_data} = read_metadata(remaining_data, metadata_count)

      {rest_data, %Node{node_count: node_count, metadata_entry_count: metadata_count, child_nodes: Enum.reverse(nodes), metadata_entries: metadata}}
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

    def calculate_value(nil), do: 0

    def calculate_value(%Node{child_nodes: [], metadata_entries: metadata_entries}) do
      Enum.sum(metadata_entries)
    end

    def calculate_value(%Node{child_nodes: child_nodes, metadata_entries: metadata_entries}) do
      Enum.map(metadata_entries, fn item ->
        calculate_value(Enum.at(child_nodes, item - 1))
      end)
      |> List.flatten |> Enum.sum()
    end
  end


  def assignment do
    {_, nodes} = "data/assign8.data"
                 |> File.read!()
                 |> String.split(" ")
                 |> Node.create_node()
    Node.calculate_value(nodes)
  end
end
