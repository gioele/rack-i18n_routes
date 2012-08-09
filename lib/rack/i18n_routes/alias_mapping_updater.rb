# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


require 'rack/i18n_routes/alias_mapping'

# An AliasMapping that updates on every `#map` call.
#
# To be used as a mapping object for {Rack::I18nRoutes} when the aliases
# needed by {Rack::I18nRoutes::AliasMapping} cannot be statically generated
# at middleware buildtime.

class Rack::I18nRoutes::AliasMappingUpdater

	# Creates a new alias-based Mapping object that updates its aliases
	# on every path normalization.
	#
	# @example Update aliases for modified user-generated content
	#
	# 	update_fn = Proc.new do
	# 		aliases = {}
	#
	# 		aliases['articles'] => {
	# 			'ita' => 'articoli',
	# 			'spa' => 'articulos',
	# 		}
	#
	# 		if @articles.any { |article| article.changed? }
	# 			@cached_articles_aliases = all_article_aliases()
	# 		end
	#
	# 		aliases['articles'][:children] = @cached_articles_aliases
	# 	end
	#
	# 	MAPPING = Rack::I18nRoutes::AliasMappingUpdater.new(update_fn)
	# 	use Rack::I18nRoutes, MAPPING
	#
	# @example Delegate the aliases generation to another class
	#
	# 	update_fn = Proc.new { @translation_mngr.updated_aliases }
	#
	# 	MAPPING = Rack::I18nRoutes::AliasMappingUpdater.new(update_fn)
	# 	use Rack::I18nRoutes, MAPPING
	#
	# @param [Proc] new_aliases_fn a parameter-less function that returns
	#                              the new aliases
	# @param [Hash] opts the options to be passed to the underlying
	#                    AliasMapping object

	def initialize(new_aliases_fn, opts = {})
		@new_aliases_fn = new_aliases_fn
		@opts = opts
	end

	# @see Rack::I18nRoutes::AliasMapping#map
	#
	# @return (see Rack::I18nRoutes::AliasMapping#map)
	#
	# @api private

	def map(path)
		alias_mapping.map(path)
	end

	# @see Rack::I18nRoutes::AliasMapping#translate_into
	#
	# @return (see Rack::I18nRoutes::AliasMapping#translate_into)
	#
	# @api private

	def translate_into(path, language)
		alias_mapping.translated_into(path, language)
	end

	# @see Rack::I18nRoutes::AliasMapping#analysis
	#
	# @return (see Rack::I18nRoutes::AliasMapping#analysis)
	#
	# @api private

	def path_analysis(path, replacement_language = :default)
		alias_mapping.analysis(path, replacement_language)
	end

	# @api private

	def alias_mapping
		aliases = @new_aliases_fn[]
		mapping = Rack::I18nRoutes::AliasMapping.new(aliases, @opts)

		return mapping
	end
end
