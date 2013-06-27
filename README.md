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
# Get your token via https://www.beeminder.com/api/v1/auth_token.json
token: my_beeminder_token

# Choose one from ['chrome', 'chromium', 'firefox']
# You *must* be already logged in to Memrise using 'Remember Password'
#   feature for this to work
memrise-browser: chromium

# This one is obvious...
memrise-goals:
  'beeminder_slug': 'memrise_course_url'
  'another_beeminder_slug': 'another_memrise_course_url'
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

* More CLI verbosity

* Allow update of individual goals
