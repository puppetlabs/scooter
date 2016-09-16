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
        same_size?(other_facts, self_facts) && same_fact_contents?(other_facts, self_facts)
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
        same_size?(other_node, self_node) && same_contents?(other_node, self_node, keys_with_expected_diffs)
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
        same_size?(other_catalog, self_catalog) &&
            same_byte_length?(other_catalog, self_catalog) &&
            same_contents?(other_catalog, self_catalog, keys_with_expected_diffs)
      end

      # Check to see if a specific report matches between two query responses
      # @param [Object] other_report - one report from query_reports
      # @param [Object] self_report - one report from query_reports
      # @return [Boolean]
      def report_match?(other_report, self_report)
        keys_with_expected_diffs = ['receive_time', 'resource_events']
        same_size?(other_report, self_report) && same_contents?(other_report, self_report, keys_with_expected_diffs)
      end

      # See if two JSON representations of Nodes, Catalogs, Facts, or Reports have the same number of fields.
      # @param [Hash] hash1 the first JSON representation to compare
      # @param [Hash] hash2 the second JSON representation to compare
      # @return [Boolean]
      def same_size?(hash1, hash2)
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

    end
  end
end
