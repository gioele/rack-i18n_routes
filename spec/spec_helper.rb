# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


LIB_DIR = File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib]))
$LOAD_PATH.unshift(LIB_DIR) unless $LOAD_PATH.include?(LIB_DIR)

require 'rack/i18n_routes'
require 'rack/test'

include Rack::Test::Methods

RSpec.configure do |config|
end

