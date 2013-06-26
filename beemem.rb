#!/usr/bin/env ruby

# Partially adapted from Muflax's fume-beeminder script

require 'tempfile'

require 'beeminder'
require 'cookie_extractor'


def perform(b_slug, m_url, config)
  # extract cookies from browser, save to Netscape type file
  cookie_filename = File.expand_path("~/.config/chromium/Default/Cookies")
  netscape_file = Tempfile.new("cookies")
  extractor = CookieExtractor::BrowserDetector.new_extractor(cookie_filename)
  memrise_cookies = extractor.extract.select { |c|
    c.include? "memrise.com"
  }.join("\n")
  netscape_file.write(memrise_cookies)
  netscape_file.close

  # wget the page
  wget_file = Tempfile.new("wget")
  wget_cmd = "wget --quiet --load-cookies #{netscape_file.path} -O #{wget_file.path} #{m_url}"
  system wget_cmd

  # regex out the useful data
  m = /(\d+) ready to water/.match(wget_file.read)
  value = m[1].to_i

  print "Found #{value} plants to water.  Uploading to Beeminder..."

  # upload to beeminder
  bee = Beeminder::User.new config["token"]
  g = bee.goal b_slug
  dp = Beeminder::Datapoint.new("timestamp" => Time.now.to_i,
                                "value" => value,
                                "comment" => "added by beem.rb")
  
  g.add dp


  # close tmpfiles
  wget_file.unlink
  netscape_file.unlink

  puts "done."
end



# get config
config = YAML.load File.open("#{Dir.home}/.beeminderrc")
# perform each goal
for b_slug, m_url in config['memrise-goals'] do
  puts "Performing goal #{b_slug}"
  perform(b_slug, m_url, config)
end
