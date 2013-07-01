#!/usr/bin/env ruby

# Partially adapted from Muflax's fume-beeminder script

require 'tempfile'

require 'beeminder'
require 'cookie_extractor'


$cookie_locations = {
  "chrome" => "~/.config/google-chrome/Default/Cookies",
  "chromium" => "~/.config/chromium/Default/Cookies",
  "firefox" => "~/.mozilla/firefox/*.default/cookies.sqlite"
}


def perform(b_slug, m_url, token, cookie_path)
  puts "Performing goal #{b_slug}"

  # extract cookies from browser, save to Netscape type file
  cookie_filename = File.expand_path(cookie_path)
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
  bee = Beeminder::User.new token
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

def main(slug=nil)
  # get config
  config = YAML.load File.open("#{Dir.home}/.beeminderrc")

  cookie_path = $cookie_locations[config['memrise-browser']]

  if config['memrise-goals'].keys.include? slug
    perform(slug, config['memrise-goals'][slug], config['token'], cookie_path)
  elsif slug == nil
    puts "Performing all goals"
    # perform each goal
    for b_slug, m_url in config['memrise-goals'] do
      perform(b_slug, m_url, config['token'], cookie_path)
    end
  else
    puts "Invalid slug name!  Choose from: #{config['memrise-goals'].keys.join(', ')}"
    usage
    exit 1
  end
end

def usage
  puts "Usage: $0 [goal_slug]"
  puts "See README: https://github.com/beneills/beemem"
end


if ARGV.length == 0
  main
elsif ARGV.length == 1 and ['--help', '-h'].include? ARGV.first
  usage
  exit 0
elsif ARGV.length == 1
  main(ARGV.first)
else
  usage
  exit 1
end





