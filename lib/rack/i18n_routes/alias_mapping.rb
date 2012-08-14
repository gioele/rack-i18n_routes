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
	# 	# translations: a french translation ("articles") and two
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
	# @param [Hash] opts extra options for the mapping
	# @option opts [Foo] :default the language key associated with the
	#                             normalized paths

	def initialize(aliases, opts = {})
		@aliases = aliases
		@default_lang = opts[:default]
	end

	# @return [String]

	def map(path)
		normalized_pieces, translated_pieces, found_langs = path_analysis(path)

		normalized_path = normalized_pieces.join('/')

		return normalized_path
	end

	# @return [String]

	def translate_into(path, language)
		normalized_pieces, translated_pieces, found_langs = path_analysis(path, language)

		return translated_pieces.join('/')
	end

	# @return [(Array<String>, Array<String>, Array<Object>)]

	def path_analysis(path, replacement_language = :default)
		path = path.to_str
		orig_pieces = path.split('/')

		normalized_pieces = []
		translated_pieces = []
		found_langs = []

		# PATH_INFO always starts with / in Rack, so we directly move
		# the initial empty piece into the normalized ones

		orig_pieces.shift
		pre_slash = ""
		normalized_pieces << pre_slash
		translated_pieces << pre_slash

		aliases = @aliases

		orig_pieces.each do |orig_piece|
			normalized, translation, lang = normalization_for(orig_piece, aliases, replacement_language)
			replacement = (normalized || orig_piece)

			normalized_pieces << replacement
			translated_pieces << translation
			found_langs << lang

			children = nil
			if !aliases.nil? && aliases.has_key?(replacement)
				children = aliases[replacement][:children]
			end

			aliases = children
		end

		if path.end_with?('/')
			normalized_pieces << ""
			translated_pieces << ""
		end

		return normalized_pieces, translated_pieces, found_langs
	end

	# @return [Array<String>] all the possible translated paths whose
	#                         normalization is `normalized_path`

	def all_paths_for(normalized_path)
		normalized_path = normalized_path.to_str
		orig_pieces = normalized_path.split('/')

		all_levels = []

		# PATH_INFO always starts with / in Rack, so we directly move
		# the initial empty piece into the normalized ones

		orig_pieces.shift
		pre_slash = ""
		all_levels << [pre_slash]

		aliases = @aliases

		orig_pieces.each do |orig_piece|
			piece_aliases = aliases[orig_piece] unless aliases.nil?

			if !piece_aliases.nil?
				translations = piece_aliases.reject { |k,v| k == :children }
				children = piece_aliases[:children]
			else
				translations = {}
				children = nil
			end

			local_paths = ([orig_piece] + translations.values).flatten
			local_paths.uniq!

			all_levels << local_paths

			aliases = children
		end

		if normalized_path.end_with?('/')
			all_levels << [""]
		end

		root_level = all_levels.first
		levels = all_levels[1..-1]

		all_paths = root_level.product(*levels).map { |ph| ph.join('/') }

		return all_paths
	end

	# @return [(String, Object)]
	#
	# @api private

	def normalization_for(piece, aliases, replacement_language)
		if aliases.nil?
			return nil, piece, @default_lang
		end

		normal_names = aliases.keys
		normal_names.each do |normal_name|
			translation_info = aliases[normal_name]
			translated_piece = piece_translation(piece, normal_name, translation_info, replacement_language)

			if piece == normal_name
				return normal_name, translated_piece, @default_lang
			end

			translations = translation_info.values.reject { |e| e.is_a? Hash }
			translation = translations.find { |s| Array(s).any? { |trans| piece == trans } }
			if translation.nil?
				next
			end

			lang = translation_info.index(translation)

			return normal_name, translated_piece, lang
		end

		# the piece is not present in the aliases

		return nil, piece, @default_lang
	end

	# @return [String]
	#
	# @api private

	def piece_translation(piece, piece_normal_name, translation_info, replacement_language)
		if replacement_language == :default || replacement_language == @default_lang
			return piece_normal_name
		end

		translated_pieces = Array(translation_info[replacement_language])

		if translated_pieces.empty?
			return piece
		end

		return translated_pieces.first
	end
end
