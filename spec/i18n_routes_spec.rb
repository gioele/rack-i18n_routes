# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


require File.join(File.dirname(__FILE__), 'spec_helper')

TEST_ALIASES = {
	'articles' => {
		'fra' => 'articles',
		'spa' => ['artículos', 'articulos'],

		:children => {
			'the-victory' => {
				'fra' => 'la-victoire',
				'spa' => 'la-victoria',
			},
			'the-block' => {
				'fra' => 'le-bloc',
				'spa' => 'el-bloque',
			},
		},
	},
	'paintings' => {
		'fra' => 'peintures',
		'spa' => 'pinturas',

		:children => {
			'gioconda' => {
				'fra' => ['joconde', 'la-joconde'],
			}
		}
	}
}

def app(*opts)
	builder = Rack::Builder.new do
		use Rack::Lint
		use Rack::I18nRoutes, *opts
		use Rack::Lint

		run lambda { |env| [200, {"Content-Type" => "text/plain"}, [""]] }
	end

	return builder.to_app
end

def request_with(path, mapping_fn)
	session = Rack::Test::Session.new(Rack::MockSession.new(app(mapping_fn)))
        session.request(path)

	return session.last_request
end

describe Rack::I18nRoutes do
	context "with a Proc mapping" do
		let(:mapping) { Proc.new { |orig_path| orig_path + "_extra" } }

		it "applies the mapping" do
			env = request_with('/articles', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles_extra'
		end

		it "saves the original path" do
			env = request_with('/articles', mapping).env
			orig_path = env[Rack::I18nRoutes::ORIG_PATH_INFO_VARIABLE]

			orig_path.should == '/articles'
		end
	end

	context "with an AliasMapping" do
		let(:mapping) { Rack::I18nRoutes::AliasMapping.new(TEST_ALIASES) }

		it "keep the same path when already normalized" do
			env = request_with('/articles', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles'
		end

		it "normalizes a path with 2 components" do
			env = request_with('/articles/le-bloc', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles/the-block'
		end

		it "normalizes a path that ends with a slash" do
			env = request_with('/articulos/le-bloc/', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles/the-block/'
		end

		it "does not change unknown paths" do
			env = request_with('/foobar', mapping).env
			path = env['PATH_INFO']

			path.should == '/foobar'
		end

		it "saves the original path" do
			env = request_with('/articulos/le-bloc', mapping).env
			orig_path = env[Rack::I18nRoutes::ORIG_PATH_INFO_VARIABLE]

			orig_path.should == '/articulos/le-bloc'
		end
	end

	context "with an AliasMappingUpdater" do
		let(:mapping) { Rack::I18nRoutes::AliasMappingUpdater.new(Proc.new { TEST_ALIASES }) }

		it "keep the same path when already normalized" do
			env = request_with('/articles', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles'
		end

		it "normalizes a path with 2 components" do
			env = request_with('/articles/le-bloc', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles/the-block'
		end

		it "normalizes a path that ends with a slash" do
			env = request_with('/articulos/le-bloc/', mapping).env
			path = env['PATH_INFO']

			path.should == '/articles/the-block/'
		end

		it "does not change unknown paths" do
			env = request_with('/foobar', mapping).env
			path = env['PATH_INFO']

			path.should == '/foobar'
		end

		it "saves the original path" do
			env = request_with('/articulos/le-bloc', mapping).env
			orig_path = env[Rack::I18nRoutes::ORIG_PATH_INFO_VARIABLE]

			orig_path.should == '/articulos/le-bloc'
		end
	end
end

describe Rack::I18nRoutes::AliasMapping do
	let(:default_lang) { 'test-lang' }
	let(:mapping) { Rack::I18nRoutes::AliasMapping.new(TEST_ALIASES, :default => default_lang) }

	context "with a :default option set" do
		describe "#path_analysis" do
			it "returns the default key for normalized paths" do
				ph, trans, found_langs = mapping.path_analysis('/paintings/gioconda/')

				found_langs.should == [default_lang, default_lang]
			end

			it "returns the non-default key when set" do
				ph, trans, found_langs = mapping.path_analysis('/articulos/la-victoire/')

				found_langs.should == ['spa', 'fra']
			end

			it "returns the default key for unknown paths" do
				ph, trans, found_langs = mapping.path_analysis('/articulos/foobar/')

				found_langs.should == ['spa', default_lang]
			end
		end

		describe "#translate_into" do
			it "translates a path" do
				ph = mapping.translate_into('/pinturas/gioconda', 'fra')

				ph.should == '/peintures/joconde'
			end

			it "translates a path with untranslated pieces" do
				ph = mapping.translate_into('/paintings/gioconda', 'spa')

				ph.should == '/pinturas/gioconda'
			end

			it "translates a path with unknown pieces" do
				ph = mapping.translate_into('/pinturas/foobar/quux', 'fra')

				ph.should == '/peintures/foobar/quux'
			end
		end
	end
end

