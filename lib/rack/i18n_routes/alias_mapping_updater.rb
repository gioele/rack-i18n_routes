# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


require 'rack/i18n_routes/alias_mapping'

class Rack::I18nRoutes::AliasMappingUpdater
	def initialize(new_aliases_fn)
		@new_aliases_fn = new_aliases_fn
	end

	def map(path)
		aliases = @new_aliases_fn[]
		alias_mapping = Rack::I18nRoutes::AliasMapping.new(aliases)

		return alias_mapping.map(path)
	end
end
