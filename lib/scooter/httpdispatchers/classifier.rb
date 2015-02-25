%w( v1 ).each do |lib|
  require "scooter/httpdispatchers/classifier/v1/#{lib}"
end
module Scooter
  module HttpDispatchers
    # Methods added here are not representative of endpoints, but are more
    # generalized to be helpers to to acquire/transform data, such as getting
    # the uuid of a node group based on the name. Be cautious about using
    # these methods if you are utilizing a dispatcher with credentials;
    # the user is not guaranteed to have privileges for all the methods
    # defined here, or the user may not be signed in. If you have a method
    # defined here that is using the connection object directly, you should
    # probably be using a method defined in the version module instead.
    module Classifier

      include Scooter::HttpDispatchers::Classifier::V1
      include Scooter::Utilities
      Rootuuid = '00000000-0000-4000-8000-000000000000'

      # This returns a tree-like hash of all node groups in the classifier; each
      # key is a uuid, each value is an array of direct children. If no direct
      # children are found, the value is an empty array. This representation
      # is useful for iterating over specific children of known node groups,
      # and is using primarily in <tt>delete_node_group_descendents</tt> and
      # <tt>delete_tree_recursion</tt>.
      # === Example return hash for default PE Installation
      #  { "00000000-0000-4000-8000-000000000000" => # root group with one child
      #     ["6d37be98-42ee-400d-a66e-ebced989546c"],
      #    "6d37be98-42ee-400d-a66e-ebced989546c" => # node group with 5 kids
      #     ["42e385ca-8fb2-442d-a0af-3b14c86d321b",
      #     "32e6a36d-59ad-44ea-8708-feb910907058",
      #     "44ebbb50-501c-45f1-8c92-95d5b0313d24",
      #     "58448b7d-3175-4695-ac32-31cf4ee25754",
      #     "00350026-bfb6-4ce7-bd06-1a1cfea445f9",
      #     "b6400234-2a61-4417-b85e-c2dcc123686b"],
      #    "42e385ca-8fb2-442d-a0af-3b14c86d321b" => [], # childless node group
      #    "32e6a36d-59ad-44ea-8708-feb910907058" => [],
      #    "44ebbb50-501c-45f1-8c92-95d5b0313d24" => [],
      #    "58448b7d-3175-4695-ac32-31cf4ee25754" => [],
      #    "00350026-bfb6-4ce7-bd06-1a1cfea445f9" => [],
      #    "b6400234-2a61-4417-b85e-c2dcc123686b" => [] }
      def get_node_group_trees_of_direct_descendents
        node_groups = get_list_of_node_groups
        groups = node_groups.map { |each| [each['id'], each['parent']] }

        # Constants for the array of tuples just created.
        id = 0
        parent = 1

        # Create root node and insert it into the tree hash.
        rootindex = groups.find_index { |e| e[id] == e[parent] }
        rootid = (groups.delete_at(rootindex))[id]
        tree = Object::Hash.new
        tree[rootid] = Object::Array.new

        # Construct the rest of the tree as a hash of
        # id => [ child1, child2,...] nodes.
        groups.each do | g |
          tree[g[id]] = Object::Array.new
          if tree.has_key?(g[parent]) then
            tree[g[parent]] << g[id]
          else
            tree[g[parent]] = Object::Array.new
            tree[g[parent]] << g[id]
          end
        end
        tree
      end

      # This method deletes all the descendents of the Rootuuid; the root group
      # can never be deleted. If you are looking to clean out a system entirely,
      # consider using <tt>import_baseline_hierarchy</tt> instead, as this
      # method doesn't clean out any classes or other settings the root group
      # might have.
      def delete_all_node_groups
        delete_node_group_descendents(get_node_group(Rootuuid))
      end

      # This takes an optional hash of node group parameters, and auto-fills
      # any required keys for node group generation. It returns the response
      # body from the server.
      def create_new_node_group_model(options={})
        # name, classes, parent are the only required keys
        name        = options['name']    || RandomString.generate
        classes     = options['classes'] || {}
        parent      = options['parent']  || Rootuuid
        rule        = options['rule']
        id          = options['id']
        environment = options['environment']
        variables   = options['variables']
        description = options['description']
        environment_trumps = options['environment_trumps']

        hash = { "name"    => name,
                 "parent"  => parent,
                 "classes" => classes }

        if environment_trumps
          hash['environment_trumps'] = environment_trumps
        end
        if rule
          hash['rule'] = rule
        end
        if environment
          hash['environment'] = environment
        end
        if variables
          hash['variables'] = variables
        end
        if description
          hash['description'] = description
        end
        if id
          hash['id'] = id
        end

        create_node_group(hash).env.body
      end

      # If for some reason your node group model is out of sync with the
      # server's state for that node group, you can use this method to just
      # update your model with the server state.
      def refresh_node_group_model(node_group_model)
        get_node_group(node_group_model['id'])
      end

      # This will delete anything that inherits from the node group specified,
      # but not the actual node group itself.
      def delete_node_group_descendents(node_group_model)
        id = node_group_model['id']
        tree = get_node_group_trees_of_direct_descendents
        tree[id].each do |childid|
          delete_tree_recursion(tree, childid)
        end
      end

      # This will return a node group hash given the name of the node group. It
      # defaults to production for the environment, since node names can be
      # the same for different environments.
      def get_node_group_by_name(name, environment='production')
        nodes = get_list_of_node_groups
        nodes.each do |node|
          if node['name'] == name && node['environment'] == environment
            return node
          end
        end
        nil # return nil if no matching name found
      end

      # This will return the node group id given the name of the node group. It
      # defaults to production for the environment, since node names can be
      # the same for different environments.
      def get_node_group_id_by_name(name, environment='production')
        nodes = get_list_of_node_groups
        nodes.each do |node|
          if node['name'] == name && node['environment'] == environment
            return node['id']
          end
        end
        nil # return nil if no matching name found
      end

      # The tree parameter required here is generated from the method
      # <tt>get_node_group_trees_with_direct_descendents</tt>. This method
      # will also delete the node_group_id as well.
      def delete_tree_recursion(tree, node_group_id)
        tree[node_group_id].each do |childid|
          delete_tree_recursion(tree, childid)
        end
        #protect against trying to delete the Rootuuid
        delete_node_group(node_group_id) if node_group_id != Rootuuid
      end

      # This method imports a bare root group into the NC, cleaning out and
      # deleting any node groups that might have been available. Consider
      # using this or <tt>delete_all_node_groups</tt> at the beginning of your
      # test, depending on requirements of the test.
      def import_baseline_hierarchy
        hierarchy = [{ "environment_trumps" => false,
                       "parent"             => Rootuuid,
                       "name"               => "default",
                       "rule"               => ["and", ["~", "name", ".*"]],
                       "variables"          => {},
                       "id"                 => Rootuuid,
                       "environment"        => "production",
                       "classes"            => {} }]
        import_hierarchy(hierarchy)
      end

      # This doesn't have a home right now, so it will exist in this module
      # until it has a proper home.
      def deep_merge(group, update_hash)
        # TODO : This doesn't work if v is ever an array.  Needs to be
        # reimplemented a la is_deep_subset?

        update_hash.each do |k,v|
          if v.is_a? Hash
            group[k] ||= {}
            deep_merge(group[k], update_hash[k])
          else
            group[k] = update_hash[k]
          end
        end
      end
      private :deep_merge

      def remove_nil_values(hash)
        hash.each do |k,v|
          case v
            when Hash
              remove_nil_values(v)
            else
              hash.delete(k) if v == nil
          end
        end
      end
      private :remove_nil_values

      # This uses a PUTs instead of a POST to update a node group; when using
      # PUTs, it will delete and replace the entire node group instead of just
      # updating the keys provided.
      def replace_node_group_with_update_hash(node_group_model, update_hash)
        merged_model = node_group_model.merge(update_hash)
        replace_node_group(merged_model['id'], merged_model)
        # no verification of the response for now, will need to write some code
        # that verifies this and takes care of array ordering
      end

      # This uses the POST method to update a node group; when using POST, it
      # will only send and update the specified keys.
      def update_node_group_with_node_group_model(node_group_model, update_hash)
        id = node_group_model['id']
        response = update_node_group(id, update_hash)

        deep_merge(node_group_model, update_hash)
        node_group_model = remove_nil_values(node_group_model)

        # check to see if the update hash had any class changes that require
        # transforms to the groups['deleted'] object
        if node_group_model['deleted'] && node_group_model['classes'] != {} && update_hash['classes']
          update_hash['classes'].each do |classname, parameters|
            if node_group_model['deleted'][classname] == nil
              next
            end
            parameters.each do |parameter, value|
              if value == nil
                node_group_model['deleted'][classname].delete(parameter)
              else
                node_group_model['deleted'][classname][parameter]['value'] = value
              end
            end
          end
        end

        # check to see if we need to delete any classes from the model's
        # node_group_model{'deleted'] key
        if node_group_model['deleted']
          node_group_model['deleted'].each do |classname, parameters|
            if node_group_model['classes'][classname] == nil || node_group_model['deleted'][classname].keys == ['puppetlabs.classifier/deleted']
              node_group_model['deleted'].delete(classname)
            end
          end
          node_group_model.delete('deleted') if node_group_model['deleted'] == {}
        end

        if node_group_model != response.env.body
          raise "node_group_model did not match the server response:\n#{node_group_model}\n#{response.env.body}"
        end

        # If we got this far, return the "model" hash.
        node_group_model
      end
    end
  end
end