rack-i8n_routes: route translated URLs to their canonical URLs
==============================================================

rack-i18n_routes is a Rack middleware component that internally re-routes URLS
that have been translated into untranslated or canonical URL.

If you manage a site that has content many languages and also localized URLs,
you will find `rack-i18n_routes` very useful, especially when used in
conjunction with `rack-i18n_best_langs`.


Features
--------

The main task of `rack-i18n_routes` is the normalization of request paths.

Path normalization rewrites the URI (actually the `PATH_INFO`) so that that the
downstream applications will have to deal with the normalized path only, instead
of a myriad of localized paths.


Examples
--------

rack-i18n_routes works like any other Rack middleware component:

    # in your server.ru rackup file
    require 'rack/i18n_routes'

    aliases = {
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

    MAPPING_FN = Rack::I18nRoutes::AliasMapping.new(aliases)

    use Rack::I18nRoutes, MAPPING_FN
    run MyApp

Requests to `/articulos/el-bloque`, `/articles/le-bloc` and even
`/articulos/le-bloc` will all be sent to `/articles/the-block`.

This component deals only with URL normalization. You can use
[`rack-i18n_best_langs`](../rack-i18n_best_langs) to automatically associate
the translated URLs to their languages.


Requirements
------------

No requirements outside Ruby >= 1.8.7 and Rack.


Install
-------

    gem install rack-i18n_routes


Author
------

* Gioele Barabucci <http://svario.it/gioele> (initial author)


Development
-----------

Code
: <https://github.com/gioele/rack-i18n_routes>

Report issues
: <https://github.com/gioele/rack-i18n_routes/issues>

Documentation
: <http://rubydoc.info/gems/rack-i18n_routes>


License
-------

This is free software released into the public domain (CC0 license).

See the `COPYING` file or <http://creativecommons.org/publicdomain/zero/1.0/>
for more details.
