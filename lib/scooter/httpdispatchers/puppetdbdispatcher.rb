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
          other_nodes = query_nodes.body
          other_catalogs = query_catalogs.body
          other_facts = query_facts.body
          other_reports = query_reports.body
        ensure
          self.host = original_host_name
        end

        self_nodes = query_nodes.body
        self_catalogs = query_catalogs.body
        self_facts = query_facts.body
        self_reports = query_reports.body

        nodes_match = nodes_match?(other_nodes, self_nodes)
        catalogs_match = catalogs_match?(other_catalogs, self_catalogs)
        facts_match = facts_match?(other_facts, self_facts)
        reports_match = reports_match?(other_reports, self_reports)

        errors = ''
        errors << "Nodes do not match - other_nodes: #{other_nodes.to_s}, self_nodes: #{self_nodes.to_s}\r\n" unless nodes_match
        errors << "Catalogs do not match - other_catalogs: #{other_catalogs.to_s}, self_catalogs: #{self_catalogs.to_s}\r\n" unless catalogs_match
        errors << "Facts do not match - other_facts: #{other_facts.to_s}, self_facts: #{self_facts.to_s}\r\n" unless facts_match
        errors << "Reports do not match - other_reports: #{other_reports.to_s}, self_reports: #{self_reports.to_s}\r\n" unless reports_match

        raise errors.chomp unless errors.empty?
      end

      # Check to see if all nodes match between two query responses
      # @param [Object] other_nodes - response from query_nodes
      # @param [Object] self_nodes - response from query_nodes
      # @return [Boolean]
      def nodes_match?(other_nodes, self_nodes=nil)
        self_nodes = query_nodes.body if self_nodes.nil?
        return false unless other_nodes.size == self_nodes.size
        other_nodes.each_index { |index | return false unless node_match? other_nodes[index], self_nodes[index]}
        true
      end

      # Check to see if a specific node matches between two query responses
      # @param [Object] other_node - one node from query_nodes
      # @param [Object] self_node - one node from query_nodes
      # @return [Boolean]
      def node_match?(other_node, self_node)
        other_node['certname'] == self_node['certname'] && other_node['facts_timestamp'] == self_node['facts_timestamp'] &&
            other_node['report_timestamp'] == self_node['report_timestamp'] && other_node['catalog_timestamp'] == self_node['catalog_timestamp']
      end
      private :node_match?

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

      # Check to see if a specific catalog matches between two query responses
      # @param [Object] other_catalog - one catalog from query_catalog
      # @param [Object] self_catalog - one catalog from query_catalog
      # @return [Boolean]
      def catalog_match?(other_catalog, self_catalog)
        other_catalog['catalog_uuid'] == self_catalog['catalog_uuid'] && other_catalog['producer_timestamp'] == self_catalog['producer_timestamp']
      end
      private :catalog_match?

      # Check to see if all facts match between two query responses
      # @param [Object] other_facts - response from query_facts
      # @param [Object] self_facts - response from query_facts
      # @return [Boolean]
      def facts_match?(other_facts, self_facts=nil)
        self_facts = query_facts.body if self_facts.nil?
        return false unless other_facts.size == self_facts.size
        other_facts.each_index { |index| return false unless other_facts[index] == self_facts[index] }
        true
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

      # Check to see if a specific report matches between two query responses
      # @param [Object] other_report - one report from query_reports
      # @param [Object] self_report - one report from query_reports
      # @return [Boolean]
      def report_match?(other_report, self_report)
        other_report['hash'] == self_report['hash'] && other_report['producer_timestamp'] == self_report['producer_timestamp']
      end
      private :report_match?
    end
  end
end
