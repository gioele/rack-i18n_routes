# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


require 'rack'

# A middleware component to route translated URLs to their canonical URL.
#
# @example Basic setup with `AliasMapping`
#
# 	require 'rack/i18n_routes'
#
# 	aliases = {
# 		'articles' => {
# 			'fra' => 'articles',
# 			'spa' => ['artículos', 'articulos'],
#
# 			:children => {
# 				'the-victory' => {
# 					'fra' => 'la-victoire',
# 					'spa' => 'la-victoria',
# 				},
# 				'the-block' => {
# 					'fra' => 'le-bloc',
# 					'spa' => 'el-bloque',
# 				},
# 			},
# 		},
#
# 		'paintings' => {
# 			'fra' => 'peintures',
# 			'spa' => 'pinturas',
# 		}
# 	}
#
# 	MAPPING_FN = Rack::I18nRoutes::AliasMapping.new(aliases)
#
# 	use Rack::I18nRoutes, MAPPING_FN
# 	run MyApp
#
# 	# /articulos/el-bloque => /articles/the-block
# 	# /articles/le-bloc => /articles/the-block
# 	# /articulos/le-block => /articles/the-block

class Rack::I18nRoutes

	ORIG_PATH_INFO_VARIABLE = 'rack.i18n_routes_orig_PATH_INFO'

	# Set up an i18n routing table.
	#
	# @overload initialize(app, url_mapper)
	#
	# 	Uses the `#map` method of `url_mapper` to derive the normalized
	# 	path.
	#
	# 	@example
	# 		aliases = {
	# 			'articles' => {
	# 				'fra' => 'articles',
	# 				'spa' => ['artículos', 'articulos'],
	#
	# 				:children => {
	# 					'the-victory' => {
	# 						'fra' => 'la-victoire',
	# 						'spa' => 'la-victoria',
	# 					},
	# 					'the-block' => {
	# 						'fra' => 'le-bloc',
	# 						'spa' => 'el-bloque',
	# 					},
	# 				},
	# 			},
	# 		}
	#
	# 		MAPPING = Rack::I18nRoutes::AliasMapping.new(aliases)
	# 		use Rack::I18nRoutes, MAPPING
	#
	# 	@param app the downstream Rack application
	# 	@param [#map] url_mapper the mapper that will perform the
	# 	                         path normalization
	#
	# 	@see Rack::I18nRoutes::AliasMapping#initialize
	# 	@see Rack::I18nRoutes::AliasMappingUpdater#initialize
	#
	# @overload initialize(app, url_mapping_fn)
	#
	# 	Uses the passed function to derive the normalized path.
	#
	# 	@example
	# 		MAPPING_FN = Proc.new do |orig_path|
	# 			orig_path.sub(r{^/it/}, '/italian/')
	# 			orig_path.sub('/ristorante/', '/restaurant/')
	# 			orig_path.sub('/ostello/', '/hostell/')
	# 		end
	# 		use Rack::I18nRoutes, MAPPING_FN
	#
	#
	# 	@param app the downstream Rack application
	# 	@param [Proc|lambda] url_mapping_fn the function used to
	# 	                                    perform the path
	# 	                                    normalization

	def initialize(app, path_lookup)
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

		env[ORIG_PATH_INFO_VARIABLE] = path
		env['PATH_INFO'] = normalized_path

		return @app.call(env)
	end
end

require 'rack/i18n_routes/alias_mapping'
require 'rack/i18n_routes/alias_mapping_updater'
