# A Jekyll plugin to convert .styl to .css
# https://gist.github.com/988201
# This plugin requires the stylus gem, do:
# $ [sudo] gem install stylus

# See _config.yml above for configuration options.

# Caveats:
# 1. Files intended for conversion must have empty YAML front matter a the top.
#    See all.styl above.
# 2. You can not @import .styl files intended to be converted.
#    See all.styl and individual.styl above.

# Modified to support Nib, Liquid, and my buildtime renaming

module Jekyll
  class StylusConverter < Converter
    safe true

    priority :low

    def setup
      return if @setup
      require 'stylus'
      Stylus.compress = @config['stylus']['compress'] if @config['stylus']['compress']
      Stylus.use @config['stylus']['use'] if @config['stylus']['use']
      Stylus.paths << @config['stylus']['path'] if @config['stylus']['path']
      @setup = true
    rescue LoadError
      STDERR.puts 'You are missing a library required for Stylus. Please run:'
      STDERR.puts '  $ [sudo] gem install stylus'
      raise FatalException.new('Missing dependency: stylus')
    end

    def matches(ext)
      ext =~ /styl/i
    end

    def output_ext(ext)
      new_ext = '.css'

      # if @config['stylus']['compress']
      #   new_ext = '.min' + new_ext
      # end

      if @config['buildtime']
        return '.' + @config['buildtime'] + new_ext
      else
        return new_ext
      end
    end

    def convert(content)
      begin
        setup
        compiled_content = Stylus.compile content
        info = { :filters => [Jekyll::Filters], :registers => { :site => Jekyll::Site, :config => @config } }
        Liquid::Template.parse(compiled_content).render({}, info)
      rescue => e
        puts "Stylus Exception: #{e.message}"
      end
    end
  end
end