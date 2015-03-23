module Scooter
  module Utilities
    module BeakerUtilities
      extend Beaker::DSL

      # Beaker and ec2 don't play nice with getting the public ip. It is only set during
      # initial provision and can be over-ridden. If you also have to run the script several times,
      # or are using an existing set of nodes for testing, beaker has no way to get the
      # ec2 instanes public ip address, mostly because the box it self does not expose it anywhere.
      # According to the docs, you can curl the below to get it
      # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html
      def self.get_public_ip(host)
        if host['hypervisor'] == 'ec2'
          on(host, "curl http://169.254.169.254/latest/meta-data/public-ipv4").stdout
        else
          self.ip
        end
      end

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
