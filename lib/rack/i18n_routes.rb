# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


require 'rack'

class Rack::I18nRoutes
	def initialize(app, path_lookup, opts = {})
		@app = app

		@path_lookup = path_lookup
	end

	def call(env)
		path = env['PATH_INFO']
		normalized_path = if @path_lookup.respond_to?(:map)
			@path_lookup.map(path)
		else
			@path_lookup[path]
		end

		env['rack.i18n-routes_PATH_INFO'] = path
		env['PATH_INFO'] = normalized_path

		return @app.call(env)
	end
end

require 'rack/i18n_routes/alias_mapping'
require 'rack/i18n_routes/alias_mapping_updater'
