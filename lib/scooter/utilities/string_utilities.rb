module Scooter
  module Utilities
    module StringUtilities

      class RandomString
        def self.generate(length = 32)
          characters = [('0'..'9'), ('a'..'z'), ('A'..'Z')]
          characters = characters.map{ |i| i.to_a }.flatten
          (0...length).map{ characters[rand(characters.length)] }.join
        end
      end

      # Create a string of two-byte Cyrillic characters.
      class RandomTwoByteUnicodeString
        def self.generate(length = 32)
          characters  = (0x0400..0x04FF).to_a.map {|e| e.chr(Encoding::UTF_8) }
          (0...length).map{ characters[rand(characters.length)] }.join
        end
      end

      # Create some single-byte characters outside the ASCII 7-bit range.
      class RandomHighbitString
        def self.generate(length = 32)
          characters = (0x80..0xFF).to_a.map {|e| e.chr }
          (0...length).map{ characters[rand(characters.length)] }.join
        end
      end

    end
  end
end

