require 'uri'
require 'rack'

require 'haml'
require 'rdiscount'
require 'RedCloth'
require 'tilt'

class RawTemplate < Tilt::Template
  def prepare
    data
  end

  def precompiled_template(locals)
    data
  end

  def evaluate(*args)
    data
  end
end
Tilt.register 'html', RawTemplate
Tilt.register 'css',  RawTemplate

module FluffyBarbarian
  class Application
    include Rack::Utils
    alias_method :h, :escape_html

    # etag probably only useful outside of heroku
    # use Rack::ETag

    # set this much lower if you're not on heroku
    #   (i.e. if you don't have a reverse proxy)
    # expires(60*60*24*10, :public)

    def development?
      ENV['RACK_ENV'] == 'development'
    end

    def production?
      ENV['RACK_ENV'] == 'production'
    end

    def template_dir; "templates"; end
    def content_dir; "content"; end
    def layout; "layout"; end

    def render(*args)
      if args.first.is_a? Hash
        options = args.first
        t = options.delete(:template)
      else
        t = args.shift
        options = args.shift || {}
      end
      c = options.delete(:content)
      l = options.has_key?(:layout) ? options.delete(:layout) : layout

      locals = options.delete(:locals) || locals || {}

      if t
        output = Tilt.new(guess_file(template_dir, t)).render(self, locals)
        output = Tilt.new(guess_file(template_dir, l)).render(self, locals) { output } if l
      elsif c
        output = Tilt.new(guess_file(content_dir, c)).render(self, locals)
      else
        raise ArgumentError
      end

      output
    end

    def guess_file(dir, path)
      dir = dir.to_s
      path = path.to_s

      return path if File.exists? path

      path = File.join(dir, path)
      return path if File.exists? path

      return Dir["#{path}*"].first
    end
  end
end
