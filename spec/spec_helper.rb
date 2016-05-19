require 'scooter'
RSpec.configure do |c|

end

def random_string
  (0...10).map { ('a'..'z').to_a[rand(26)] }.join
end
