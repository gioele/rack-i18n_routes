# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


# Describe translated paths as aliases for the normalized ones.
#
# To be used as a mapping object for {Rack::I18nRoutes}.
#
# If the list of aliases is not known at buildtime, you can use a
# {Rack::I18nRoutes::AliasMappingUpdater}.

class Rack::I18nRoutes::AliasMapping

	# Create a new alias-based Mapping object.
	#
	# The aliases as stored in a hash. Each keys of the hash contain
	# a normalized path; its value contains another hash that associates
	# _ids_ to one or more translations. The special id `:children` is
	# used to specify the aliases of subpaths.
	#
	# @example A basic set of aliases
	#
	# 	# "articles" is the normalized path; there are three available
	# 	# translations: an french translation ("articles") and two
	# 	# spanish translations ("artículos" and "articulos").
	#
	# 	'articles' => {
	# 		'fra' => 'articles',
	# 		'spa' => ['artículos', 'articulos'],
	# 	}
	#
	# @example A set of aliases with subpaths
	#
	# 	# a special id `:children` is used to specify the aliases of
	# 	# subpaths
	#
	# 	'articles' => {
	# 		'fra' => 'articles',
	# 		'spa' => ['artículos', 'articulos'],
	#
	# 		:children => {
	# 			'the-victory' => {
	# 				'fra' => 'la-victoire',
	# 				'spa' => 'la-victoria',
	# 			},
	# 			'the-block' => {
	# 				'fra' => 'le-bloc',
	# 				'spa' => 'el-bloque',
	# 			},
	# 		},
	# 	}
	#
	# @example An AliasMapping as mapping object in I18nRoutes
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
	# 	}
	#
	# 	MAPPING = Rack::I18nRoutes::AliasMapping.new(aliases)
	# 	use Rack::I18nRoutes, MAPPING
	#
	# @param [Hash] aliases the aliases

	def initialize(aliases)
		@aliases = aliases
	end

	def map(path)
		orig_pieces = path.split('/')
		normalized_pieces = []

		normalized_pieces << orig_pieces.shift

		aliases = @aliases

		orig_pieces.each do |orig_piece|
			normalized = normalization_for(orig_piece, aliases)
			replacement = (normalized || orig_piece)

			normalized_pieces << replacement

			if !aliases.nil?
				subaliases = aliases[replacement]
				aliases = subaliases[:children] unless subaliases.nil?
			end
		end

		if path.end_with?('/')
			normalized_pieces << ""
		end

		return normalized_pieces.join('/')
	end

	def normalization_for(piece, aliases)
		if aliases.nil?
			return nil
		end

		entities = aliases.keys
		entities.each do |entity|
			if piece == entity
				return entity
			end

			subentities = aliases[entity].values.reject { |e| e.is_a? Hash }
			if subentities.any? { |subentity| Array(subentity).any? { |sube| piece == sube } }
				return entity
			end
		end

		return nil
	end
end
