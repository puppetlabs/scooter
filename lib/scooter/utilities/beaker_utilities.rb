module Scooter
  module Utilities
    module BeakerUtilities
      extend Beaker::DSL

      def self.pe_ca_cert_file(master)
        ca_cert = on(master, "cat `puppet agent --configprint localcacert`").stdout

        cert_dir = Dir.mktmpdir("pe_certs")

        ca_cert_file = File.join(cert_dir, "cacert.pem")
        File.open(ca_cert_file, "w+") do |f|
          f.write(ca_cert)
        end
        ca_cert_file
      end

      def self.pe_private_key(master)
        on(master, "cat `puppet agent --configprint hostprivkey`").stdout
      end

      def self.pe_hostcert(master)
        on(master, "cat `puppet agent --configprint hostcert`").stdout
      end
    end
  end
end