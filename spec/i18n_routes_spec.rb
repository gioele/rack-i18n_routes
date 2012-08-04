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
	}
}

describe Rack::I18nRoutes do
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
	end
end

