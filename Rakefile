# This is free software released into the public domain (CC0 license).
#
# See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
# for more details.


begin
	require 'bones'
rescue LoadError
	abort '### Please install the "bones" gem ###'
end

Bones {
	name     'rack-i18n_routes'
	authors  'Gioele Barabucci'
	email    'gioele@svario.it'
	url      'https://github.com/gioele/rack-i18n_routes'

	version  '0.2.dev'

	ignore_file  '.gitignore'

	depend_on 'rack'
	depend_on 'rack-test', :development => true
	depend_on 'bones-rspec', :development => true
}

task :default => 'spec:run'
task 'gem:release' => 'spec:run'
