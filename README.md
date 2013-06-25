Beemem.rb
=========

Keep the plants requiring watering down!

http://memrise.com
http://beeminder.com

Get it working
--------------

Put something like this into ~/.beeminderrc:

```yaml
 ---
token: my_token_from_beeminder->your_account->settings

memrise-goals:
  'beeminder_slug': 'memrise_course_url'
```

*e.g. slug = 'memrise-intermediate-harvest-backlog' and url = 'http://www.memrise.com/course/845/intermediate-french-2/'*


and install via:

```shell
(sudo) gem install beeminder cookie_extractor
(sudo) mv beemem.rb ~/bin
```

Now, make sure that you've logged in to Memrise recently using Chromium (we steal its cookies), and voilà!

```shell
beemem.rb
```

TODO
----

* Separate cookie magic into new gem (this might be really useful for people interacting with non-API secure pages).

* Support Firefox

* More CLI verbosity

* Allow update of individual goals
