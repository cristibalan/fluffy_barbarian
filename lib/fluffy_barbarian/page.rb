module FluffyBarbarian
  class Page
    def self.all(path="content/_pages")
      @pages = Dir[File.join(path, "**", "*")].select{ |f| File.file? f }
      @pages = @pages.sort.map do |file|
        title = File.basename(file, ".*").tidy
        dir = file.split("/")[2..-2].map{ |dir| dir.parameterize }.join("/")
        slug = title.parameterize
        { :title => title, :path => File.expand_path(file), :type => "page",
          :autoslug => slug,
          :slug => slug,
          :dir => dir,
          :url => "#{"/#{dir}" if dir != ""}/#{slug}",
          :extname => File.extname(file) }
      end
    end

    def self.find(splat, slug)
      dir = ""
      # scope by directory first
      if splat
        dir = splat.split("/").tidy.map{ |part| part.parameterize }.join("/")

        @page = all.find{|page| page[:dir] == dir && page[:slug] == slug.parameterize }
      end
      @page ||= all.find{|page| page[:slug] == slug.parameterize }

      return nil unless @page

      if slug != @page[:slug] || dir != @page[:dir]
        @page[:fuzzy] = true
      else
        @page[:content] ||= Tilt.new(@page[:path]).render
      end

      @page
    end
  end
end
