module Scooter
  module Utilities
    module BeakerUtilities
      extend Beaker::DSL

      # # Beaker and ec2 don't play nice with getting the public ip. It is only set during
      # # initial provision and can be over-ridden. If you also have to run the script several times,
      # # or are using an existing set of nodes for testing, beaker has no way to get the
      # # ec2 instanes public ip address, mostly because the box it self does not expose it anywhere.
      # # According to the docs, you can curl the below to get it
      # # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-instance-addressing.html
      # def self.get_public_ip(host)
      #   if host['hypervisor'] == 'ec2'
      #     on(host, "curl http://169.254.169.254/latest/meta-data/public-ipv4").stdout
      #   else
      #     host.ip
      #   end
      # end

      def self.pe_ca_cert_file(master)
        ca_cert = on(master, "cat `puppet config print localcacert`").stdout

        ca_cert_file = write_cert_file("cacert.pem", ca_cert)

        ca_cert_file
      end

      def self.write_cert_file(file, content)
        tmp_dir = Dir.mktmpdir('pe_certs')
        file_path = File.join(tmp_dir, file)
        File.open(file_path, "w+") do |f|
          f.write(content)
        end
        file_path
      end

      def self.pe_private_key_file(master)
        pkey = on(master, "cat `puppet config print hostprivkey`").stdout

        pkey_file = write_cert_file("pkey.pem", pkey)

        pkey_file
      end

      def self.pe_hostcert_file(master)
        cert = on(master, "cat `puppet config print hostcert`").stdout

        cert_file = write_cert_file("host_cert.pem", cert)

        cert_file
      end
    end
  end
end
