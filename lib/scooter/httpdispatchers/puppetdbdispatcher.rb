%w( v4 ).each do |lib|
  require "scooter/httpdispatchers/puppetdb/v4/#{lib}"
end
module Scooter
  module HttpDispatchers
    class PuppetdbDispatcher < HttpDispatcher
      include Scooter::HttpDispatchers::PuppetdbDispatcher::V4

      # Sets the path for puppetdb
      # @param [Object] connection - the Faraday connection
      def set_puppetdb_path(connection=self.connection)
        set_url_prefix
        connection.url_prefix.path = '/pdb'
        connection.url_prefix.port = 8081
      end

      # Used to compare replica puppetdb to master. Raises exception if it does not match.
      # @param [BeakerHost] host_name
      def database_matches_self?(host_name)
        original_host_name = self.host
        begin
          self.host = host_name
          initialize_connection
          other_nodes    = query_nodes.body
          other_catalogs = query_catalogs.body
          other_facts    = query_facts.body
          other_reports  = query_reports.body
        ensure
          self.host = original_host_name
          initialize_connection
        end

        self_nodes    = query_nodes.body
        self_catalogs = query_catalogs.body
        self_facts    = query_facts.body
        self_reports  = query_reports.body

        nodes_match    = nodes_match?(other_nodes, self_nodes)
        catalogs_match = catalogs_match?(other_catalogs, self_catalogs)
        facts_match    = facts_match?(other_facts, self_facts)
        reports_match  = reports_match?(other_reports, self_reports)

        errors = ''
        errors << "Nodes do not match\r\n" unless nodes_match
        errors << "Catalogs do not match\r\n" unless catalogs_match
        errors << "Facts do not match\r\n" unless facts_match
        errors << "Reports do not match\r\n" unless reports_match

        @faraday_logger.warn(errors.chomp) unless errors.empty?
        errors.empty?
      end

      # Compares Replica PuppetDB with Master PuppetDB, to make sure Master PuppetDB has synced to Replica PuppetDB.
      #
      # N.B.: this uses a weird definition of "synced". We're NOT making sure the two PuppetDBs are exactly the same.
      # We're just checking that the replica DB doesn't contain any records that aren't also in the master, and that
      # the replica has at least one report from each node. We do this because there's a race condition-y window where
      # an agent may have delivered a report to the Master PuppetDB, but the Replica PuppetDB hasn't picked it up yet.
      # @param [BeakerHost] replica_host_name
      # @param [Array] agents all the agents in the SUT, in the form of BeakerHost instances
      def replica_db_synced_with_master_db?(replica_host_name, agents)
        master_host_name = self.host
        begin
          self.host = replica_host_name
          initialize_connection
          replica_nodes    = query_nodes.body
          replica_catalogs = query_catalogs.body
          replica_facts    = query_facts.body
          replica_reports  = query_reports.body
        ensure
          self.host = master_host_name
          initialize_connection
        end
        master_nodes    = query_nodes.body
        master_catalogs = query_catalogs.body
        master_facts    = query_facts.body
        master_reports  = query_reports.body

        nodes_synced    = nodes_synced?(agents, replica_nodes, master_nodes)
        catalogs_synced = catalogs_synced?(agents, replica_catalogs, master_catalogs)
        facts_synced    = facts_synced?(replica_facts, master_facts)
        reports_synced  = reports_synced?(agents, replica_reports, master_reports)

        errors = ''
        errors << "Nodes not synced\r\n" unless nodes_synced
        errors << "Catalogs not synced\r\n" unless catalogs_synced
        errors << "Facts not synced\r\n" unless facts_synced
        errors << "Reports not synced\r\n" unless reports_synced

        @faraday_logger.warn(errors.chomp) unless errors.empty?
        errors.empty?
      end

      private

      # Check to see if all nodes match between two query responses
      # @param [Object] other_nodes - response from query_nodes
      # @param [Object] self_nodes - response from query_nodes
      # @return [Boolean]
      def nodes_match?(other_nodes, self_nodes=nil)
        self_nodes = query_nodes.body if self_nodes.nil?
        return false unless other_nodes.size == self_nodes.size
        other_nodes.each_index { |index| return false unless node_match? other_nodes[index], self_nodes[index] }
        true
      end

      # Check to see if all catalogs match between two query responses
      # @param [Object] other_catalogs - response from query_catalogs
      # @param [Object] self_catalogs - response from query_catalogs
      # @return [Boolean]
      def catalogs_match?(other_catalogs, self_catalogs=nil)
        self_catalogs = query_catalogs.body if self_catalogs.nil?
        return false unless other_catalogs.size == self_catalogs.size
        other_catalogs.each_index { |index| return false unless catalog_match?(other_catalogs[index], self_catalogs[index]) }
        true
      end

      # Check to see if all facts match between two query responses
      # @param [Object] other_facts - response from query_facts
      # @param [Object] self_facts - response from query_facts
      # @return [Boolean]
      def facts_match?(other_facts, self_facts=nil)
        self_facts = query_facts.body if self_facts.nil?
        same_num_elements?(other_facts, self_facts) && same_fact_contents?(other_facts, self_facts)
      end

      # Check to see if all reports match between two query responses
      # @param [Object] other_reports - response from query_reports
      # @param [Object] self_reports - response from query_reports
      # @return [Boolean]
      def reports_match?(other_reports, self_reports=nil)
        self_reports = query_reports.body if self_reports.nil?
        return false unless other_reports.size == self_reports.size
        other_reports.each_index { |index| return false unless report_match?(other_reports[index], self_reports[index]) }
        true
      end

      # Check to see if a specific node matches between two query responses
      # @param [Object] other_node - one node from query_nodes
      # @param [Object] self_node - one node from query_nodes
      # @return [Boolean]
      def node_match?(other_node, self_node)
        keys_with_expected_diffs = ['facts_timestamp', 'catalog_timestamp']
        same_num_elements?(other_node, self_node) && same_contents?(other_node, self_node, keys_with_expected_diffs)
      end

      # Check to see if a specific catalog matches between two query responses.
      # We check to make sure byte lengths are the same because often both catalogs contain the same data, but
      # in different order. That means we can't just walk the hash keys and make sure all values match up. Instead,
      # we check certain keys explicitly (everything except 'resources' and 'edges') and assume that if the total byte
      # size of each catalog is the same, that the contents are the same even in the keys whose values we don't check.
      # @param [Object] other_catalog - one catalog from query_catalog
      # @param [Object] self_catalog - one catalog from query_catalog
      # @return [Boolean]
      def catalog_match?(other_catalog, self_catalog)
        keys_with_expected_diffs = ['resources', 'edges']
        same_num_elements?(other_catalog, self_catalog) &&
            same_byte_length?(other_catalog, self_catalog) &&
            same_contents?(other_catalog, self_catalog, keys_with_expected_diffs)
      end

      # Check to see if a specific report matches between two query responses
      # @param [Object] other_report - one report from query_reports
      # @param [Object] self_report - one report from query_reports
      # @return [Boolean]
      def report_match?(other_report, self_report)
        keys_with_expected_diffs = ['receive_time', 'resource_events']
        same_num_elements?(other_report, self_report) && same_contents?(other_report, self_report, keys_with_expected_diffs)
      end

      # See if two JSON representations of Nodes, Catalogs, Facts, or Reports have the same number of elements.
      # @param [Hash] hash1 first JSON representation to compare
      # @param [Hash] hash2 second JSON representation to compare
      # @return [Boolean]
      def same_num_elements?(hash1, hash2)
        hash1.size == hash2.size
      end

      # See if two JSON representations of Nodes, Catalogs, or Reports have the same byte length.
      # This is useful to make sure the representations contain all the same data even if that data is stored
      # in different order. This is exactly what happens when you replicate Catalogs from one PuppetDB instance
      # to another.
      # @param [Hash] hash1 the first JSON representation to compare
      # @param [Hash] hash2 the second JSON representation to compare
      # @return [Boolean]
      def same_byte_length?(hash1, hash2)
        hash1.to_s.length == hash2.to_s.length
      end

      # See if two JSON representations of Nodes, Catalogs, or Reports (but not Facts!) have the same values for
      # all fields.
      # @param [Hash] hash1 the first JSON representation to compare
      # @param [Hash] hash2 the second JSON representation to compare
      # @param [Array] keys_to_ignore any keys for which it's OK to have different values
      # @return [Boolean]
      def same_contents?(hash1, hash2, keys_to_ignore=[])
        hash1.keys.each do |key|
          next if keys_to_ignore.include?(key)
          return false unless hash1[key] == hash2[key]
        end
        true
      end

      # See if two JSON representations of Facts have the same values for all fields (though the facts' order may differ).
      # Algorithm: for each fact in the first set, scan through the entire second set looking for a matching fact.
      # @param [Array] fact_set_1 the first JSON representation of facts to compare
      # @param [Array] fact_set_2 the second JSON representation of facts to compare
      # @return [Boolean]
      def same_fact_contents?(fact_set_1, fact_set_2)
        fact_set_1.each do |fact_from_first_set|
          found_match = false
          fact_set_2.each do |fact_from_second_set|
            if fact_from_second_set == fact_from_first_set
              found_match = true
              break
            end
          end
          return false unless found_match
        end
        true
      end


      # - - - - - - - - - -
      # below here are methods to verify PuppetDB syncing for HA
      # (as opposed to the strict matching methods above, which are used to verify services DB syncing for HA)
      # - - - - - - - - - -


      # Make sure of 2 conditions:
      #   1. Master PuppetDB contains all the nodes that Replica PuppetDB contains
      #   2. Replica PuppetDB contains a node for each actual node in the environment
      # These two conditions are a minimal way to check that PuppetDB's node records have synced from Master to
      # Replica, while allowing for gaps that can happen due to syncing race conditions.
      # @param [Array] agents all of the system's agents, as an Array of BeakerHost objects
      # @param [Object] replica_nodes response from query_nodes
      # @param [Object] master_nodes response from query_nodes
      # @return [Boolean]
      def nodes_synced?(agents, replica_nodes, master_nodes=nil)
        master_nodes = query_nodes.body if master_nodes.nil?
        replica_nodes.each { |replica_node| return false unless master_has_node?(replica_node, master_nodes) }
        agents.each { |agent| return false unless replica_has_node_for_agent?(replica_nodes, agent) }
        true
      end

      # Make sure of 2 conditions:
      #   1. Master PuppetDB contains all the catalogs that Replica PuppetDB contains
      #   2. Replica PuppetDB contains a catalog for each actual node in the environment
      # These two conditions are a minimal way to check that PuppetDB's catalogs have synced from Master to
      # Replica, while allowing for gaps that can happen due to syncing race conditions.
      # @param [Array] agents all of the system's agents, as an Array of BeakerHost objects
      # @param [Object] replica_catalogs response from query_catalogs
      # @param [Object] master_catalogs response from query_catalogs
      # @return [Boolean]
      def catalogs_synced?(agents, replica_catalogs, master_catalogs=nil)
        master_catalogs = query_catalogs.body if master_catalogs.nil?
        replica_catalogs.each { |replica_catalog| return false unless master_has_catalog?(replica_catalog, master_catalogs) }
        agents.each { |agent| return false unless replica_has_catalog_for_agent?(replica_catalogs, agent) }
        true
      end

      # See if the Replica PuppetDB has a subset of the facts in Master PuppetDB. Note that values can differ
      # due to race conditions involving syncing, but certname, name, and environment must all match between
      # Replica and Master fact sets.
      # @param [Object] replica_facts response from query_facts
      # @param [Object] master_facts response from query_facts
      # @return [Boolean]
      def facts_synced?(replica_facts, master_facts=nil)
        master_facts = query_facts.body if master_facts.nil?
        replica_facts.each do |replica_fact|
          # TECH DEBT: the 'agent_specified_environment' fact is set on the scheduled agent by Beaker when created,
          # but then is unset after the scheduled agent first checks in. This makes a gap between replica and master facts.
          # We don't want to wait 2 mins for that fact to sync over to the replica, so for now, ignore it.
          # NOTE: this *might* be caused by PE-18113, and when that's resolved we might be able to start paying attention
          # to the agent_specified_environment fact again. We'll have to test and find out.
          next if replica_fact['name'] == 'agent_specified_environment'
          return false unless fact_synced?(replica_fact, master_facts)
        end
        true
      end

      # See if a single fact that's in Replica PuppetDB is also in Master PuppetDB. Note that values can differ
      # due to race conditions involving syncing, but certname, name, and environment must all match between
      # Replica and Master facts.
      # @param [Hash] replica_fact a single fact from Replica PuppetDB
      # @param [Array] master_facts all facts from Master PuppetDB, stored as Hashes
      # @return [Boolean]
      def fact_synced?(replica_fact, master_facts)
        master_facts.each do |master_fact|
          return true if ['certname', 'name', 'environment'].all? { |key| replica_fact[key] == master_fact[key] }
        end
        @faraday_logger.warn("*** fact sync failure: no Master fact matches Replica fact: #{replica_fact}")
        false
      end

      # Make sure of 2 conditions:
      #   1. Master PuppetDB contains all the reports that Replica PuppetDB contains
      #   2. Replica PuppetDB contains a report for each actual node in the environment
      # These two conditions are a minimal way to check that PuppetDB's reports have synced from Master to
      # Replica, while allowing for gaps that can happen due to syncing race conditions.
      # @param [Array] agents all of the system's agents, as an Array of BeakerHost objects
      # @param [Object] replica_reports response from query_reports
      # @param [Object] master_reports response from query_reports
      # @return [Boolean]
      def reports_synced?(agents, replica_reports, master_reports=nil)
        master_reports = query_reports.body if master_reports.nil?
        replica_reports.each { |replica_report| return false unless master_has_report?(replica_report, master_reports) }
        agents.each { |agent| return false unless replica_has_report_for_agent?(replica_reports, agent) }
        true
      end

      # See if Master PuppetDB has a copy of a particular catalog that's in Replica PuppetDB.
      # Note that all we're checking for is that the Master and Replica each contain a catalog with a
      # particular certname; we're not checking any of the other content in the catalog because of a possible
      # race condition: a node checks in with Master and updates some of the fields in the catalog for that node,
      # then the test compares field contents for the two catalogs, then the Replica syncs the new catalog.
      # In that case, the fields (except for 'certname') could be very different between Master and Replica catalogs
      # for a given node.
      # @param [Hash] replica_catalog catalog in Replica PuppetDB, that we want to look for on Master PuppetDB
      # @param [Array] master_catalogs catalogs in Master PuppetDB
      # @return [Boolean]
      def master_has_catalog?(replica_catalog, master_catalogs)
        master_catalogs.each { |master_catalog| return true if replica_catalog['certname'] == master_catalog['certname'] }
        @faraday_logger.warn("master doesn't have catalog with hash '#{replica_catalog['certname']}', which is on replica")
        false
      end

      # See if Master PuppetDB has a copy of a particular node record that's in Replica PuppetDB.
      # Note that all we're checking for is that the Master and Replica each contain a node record with a
      # particular certname; we're not checking any of the other content in the node record because of a possible
      # race condition: a node checks in with Master and updates some of the fields in its record,
      # then the test compares field contents for the two node records, then the Replica syncs the new node record.
      # In that case, the fields (except for 'certname') could be very different between Master and Replica node
      # records for a given node.
      # @param [Hash] replica_node node in Replica PuppetDB, that we want to look for on Master PuppetDB
      # @param [Array] master_nodes nodes in Master PuppetDB
      # @return [Boolean]
      def master_has_node?(replica_node, master_nodes)
        master_nodes.each { |master_node| return true if replica_node['certname'] == master_node['certname'] }
        @faraday_logger.warn("master doesn't have node with certname '#{replica_node['certname']}', which is on replica")
        false
      end

      # See if Master PuppetDB has a copy of a particular report that's found on Replica PuppetDB
      # @param [Hash] replica_report report in Replica PuppetDB, that we want to look for on Master PuppetDB
      # @param [Array] master_reports reports in Master PuppetDB
      # @return [Boolean]
      def master_has_report?(replica_report, master_reports)
        keys_with_expected_diffs = ['receive_time', 'resource_events']
        master_reports.each do |master_report|
          same_hash     = (replica_report['hash'] == master_report['hash'])
          same_contents = same_contents?(replica_report, master_report, keys_with_expected_diffs)
          return true if same_hash && same_contents
        end
        @faraday_logger.warn("master doesn't have report with hash '#{replica_report['hash']}', which is on replica")
        false
      end

      # See if the Replica PuppetDB has at least one node record for the given agent.
      # @param [Array] replica_nodes JSON representations of the nodes stored in Replica PuppetDB
      # @param [BeakerHost] agent the agent that Replica PuppetDB should contain a node record for
      # @return [Boolean]
      def replica_has_node_for_agent?(replica_nodes, agent)
        replica_nodes.each { |replica_node| return true if replica_node['certname'] == agent.hostname }
        @faraday_logger.warn("replica doesn't have any nodes for certname '#{agent.hostname}'")
        false
      end

      # See if the Replica PuppetDB has at least one catalog for the given agent.
      # @param [Array] replica_reports JSON representations of the reports stored in Replica PuppetDB
      # @param [BeakerHost] agent the agent that Replica PuppetDB should contain at least one report from
      # @return [Boolean]
      def replica_has_report_for_agent?(replica_reports, agent)
        replica_reports.each { |replica_report| return true if replica_report['certname'] == agent.hostname }
        @faraday_logger.warn("replica doesn't have any reports for certname '#{agent.hostname}'")
        false
      end

      # See if the Replica PuppetDB has at least one catalog for the given agent.
      # @param [Array] replica_catalogs JSON representations of the catalogs stored in Replica PuppetDB
      # @param [BeakerHost] agent agent that Replica PuppetDB should contain at least one catalog for
      # @return [Boolean]
      def replica_has_catalog_for_agent?(replica_catalogs, agent)
        replica_catalogs.each { |replica_catalog| return true if replica_catalog['certname'] == agent.hostname }
        @faraday_logger.warn("replica doesn't have any catalogs for certname '#{agent.hostname}'")
        false
      end
    end
  end
end
