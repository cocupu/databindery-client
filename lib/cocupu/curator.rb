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
      source_field_values.reject! do |v|
        v.nil? || v.empty?
      end
      source_field_values.each do |value_to_spawn|
        puts "VALUE: #{value_to_spawn}"
        destination_node_data = {destination_field_name=>value_to_spawn}
        destination_node = Cocupu::Node.find_or_create("identity"=>identity_id, "pool"=>pool_id, "node" => {"model_id"=>destination_model_id, "data"=>destination_node_data})
        source_nodes_to_process = source_nodes.select {|sn| sn.data[source_field_name] == value_to_spawn}
        source_nodes_to_process.each do |sn|
          sn.associations[association_code] = [destination_node.persistent_id]
          puts "    #{sn.persistent_id} #{association_code}: #{sn.associations[association_code]}"
          if opts[:delete_source_value] == true
            sn.values["data"].delete(source_field_name)
          end
          unless opts[:also_move].nil?
            opts[:also_move].each do |fn|
              if fn.instance_of?(String)
                move_field(fn, sn, destination_node)
              elsif fn.instance_of?(Hash)
                move_field(fn.keys.first, sn, destination_node, rename_to: fn.values.first)
              end
            end
          end
          unless opts[:also_copy].nil?
            opts[:also_copy].each do |fn|
              if fn.instance_of?(String)
                copy_field(fn, sn, destination_node)
              elsif fn.instance_of?(Hash)
                copy_field(fn.keys.first, sn, destination_node, rename_to: fn.values.first)
              end            
            end
          end
          sn.save
        end
        destination_node.save
      end
      return source_field_values
    end
    
    # Move a field and its values from source_node to destination_node
    # This performs copy_field and then deletes the field from the source node.
    def self.move_field(field_name, source_node, destination_node, opts={})
      copy_field(field_name, source_node, destination_node, opts)
      source_node.values["data"].delete(field_name)
    end
    
    # Copy a field and its values from source_node to destination_node
    # If the destination node already has values in this field stored as an Array, it appends the ones being copied.
    # If you want to use a new field code in the destination node, pass the new code as the value of :rename_to in the opts Hash
    # This does not delete the field from the source node.  To do that, use move_field.
    def self.copy_field(field_name, source_node, destination_node, opts={})
      if opts[:rename_to].nil? || opts[:rename_to].empty?
        dest_field_name = field_name
      else
        dest_field_name = opts[:rename_to]
      end
      if destination_node.values["data"][dest_field_name].instance_of?(Array)
        destination_node.values["data"][dest_field_name] << source_node.values["data"][field_name]
      else
        destination_node.values["data"][dest_field_name] = source_node.values["data"][field_name]
      end
    end
    

    
  end
end