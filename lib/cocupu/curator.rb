module Cocupu
  class Curator

    # Spawn new :destination_model nodes using the :source_field_name field from :source_model nodes, 
    # setting the extracted value as the :destination_field_name field on the resulting spawned nodes.
    #
    # @param identity_id
    # @param pool_id
    # @param source_model_id Model whose field(s) you're spawning new Nodes from
    # @param source_field_name field name of field to spawn
    # @param association_code Code for the association to use to point from source nodes to spawned nodes
    # @param destination_model_id model to spawn new nodes of
    # @param destination_field_name field name to set on spawned nodes
    def self.spawn_from_field(identity_id, pool_id, source_model_id, source_field_name, association_code, destination_model_id, destination_field_name, opts={})
      identity_id = identity_id.short_name unless identity_id.instance_of?(String)
      pool_id = pool_id.short_name unless pool_id.instance_of?(String)

      source_nodes = Cocupu::Node.find(identity_id, pool_id, :model_id=>source_model_id)
      source_field_values = source_nodes.map {|sn| sn.data[source_field_name]}.uniq
      source_field_values.delete(nil)
      source_field_values.each do |value_to_spawn|
        destination_node_data = {destination_field_name=>value_to_spawn}
        destination_node = Cocupu::Node.find_or_create("identity"=>identity_id, "pool"=>pool_id, "node" => {"model_id"=>destination_model_id, "data"=>destination_node_data})
        source_nodes_to_process = source_nodes.select {|sn| sn.data[source_field_name] == value_to_spawn}
        source_nodes_to_process.each do |sn|
          sn.associations[association_code] = [destination_node.persistent_id]
          sn.values["data"].delete(source_field_name)
          sn.save
        end
      end
    end
  end
end