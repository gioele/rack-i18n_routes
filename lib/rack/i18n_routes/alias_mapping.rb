# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


class Rack::I18nRoutes::AliasMapping
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
