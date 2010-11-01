module FluffyBarbarian
  class Index
    public
      def initialize(path="content/_posts")
        @path       = path
        @index_path = "#{@path}.mkd"
        @parsed     = nil
        @on_disk    = nil
      end

      def parsed(text=nil)
        return @parsed if @parsed

        text ||= File.read(@index_path)
        @parsed = []
        posts = text.split(/^(# .*$)\n/).tidy
        posts.each_with_index do |title, index|
          next unless title[0..1] == "# "

          post = parse_meta(posts[index+1])
          post[:title] = title[2..-1].tidy

          post[:autoslug] = post[:title].parameterize
          unless post[:slug]
            post[:slug] = post[:autoslug]
          end
          post[:url] = "/#{post[:happened_on].tr("-","/")}/#{post[:slug]}"

          @parsed << post
        end

        @parsed
      end

      def on_disk(path=nil)
        return @on_disk if @on_disk

        path ||= @path

        @on_disk = Dir[File.join(path, "**", "*")].select{ |f| File.file? f }
        @on_disk = @on_disk.sort.map do |file|
          title = File.basename(file, ".*").tidy
          { :title => title, :path => File.expand_path(file),
            :autoslug => title.parameterize,
            :extname => File.extname(file) }
        end
      end

      def sane?
        return false if parsed.length != on_disk.length
      end

      def all
        @all ||= parsed.map do |post|
          if file = on_disk.find{ |f| f[:autoslug] == post[:autoslug] }
            post[:path]    = file[:path]
            post[:extname] = file[:extname]
            post
          end
        end.compact.each_with_index do |post, index|
          post[:index] = index
          post[:type] = "post"
          post[:updated_on] = updated_on(post)
        end
      end

      def find(splat, slug)
        @post = all.find{|p| p[:slug] == slug.parameterize }

        return nil unless @post

        dir = splat.split("/").tidy.map{ |part| part.parameterize }.join("/")
        if slug != @post[:slug] || dir != @post[:happened_on].tr("-","/")
          @post[:fuzzy] = true
        else
          @post[:content] ||= Tilt.new(@post[:path]).render
          @post[:previous] = all[@post[:index] - 1] if @post[:index] > 0
          @post[:next] = all[@post[:index] + 1]
        end

        @post
      end

    private
      # according to RFC3339. Example: 2003-12-13T18:30:02Z
      def updated_on(post)
        title = post[:title].gsub(" ", "")
        # so that we don't have two posts on the same date :D
        minutes = title[0].chr.downcase[0] - 87
        seconds = title[1].chr.downcase[0] - 87
        "#{post[:written_on]}T12:#{minutes}:#{seconds}Z"
      end

      def parse_meta(raw_meta)
        meta = {}
        raw_meta.split("\n").tidy.each do |line|
          if !line.include? ":"
            dates = line.split(",").tidy.map { |d|
              Date.parse(d.gsub(/\D/, "-")).strftime("%Y-%m-%d")
            }
            meta[:happened_on] = dates[0]
            meta[:written_on]  = dates[1] || meta[:happened_on]
          else
            parts = line.split(":").tidy
            key = parts[0].to_sym
            case key
            when :tags
              meta[key] = parts[1].split(",").tidy
            when :location
              # can be
              # Buenos Aires
              # Caranavi(-15.833,-67.565)
              location = parts[1].split(/\(|\)/)
              meta[key] = [ location[0], location[1] || location[0] ]
            else
              meta[key] = parts[1]
            end
          end
        end
        meta
      end
  end
end
