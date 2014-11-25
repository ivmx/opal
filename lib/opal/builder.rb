require 'opal/builder/path_reader'
require 'opal/builder/processors'
require 'opal/builder/cached_asset'
require 'set'

module Opal
  class Builder
    include BuilderProcessors

    attr_accessor :cache_store

    # A set of paths which have been processed already.
    attr_reader :processed

    # Array of compiled assets (either cached, or re-processed).
    attr_reader :assets

    def initialize(options = nil)
      (options || {}).each_pair do |k,v|
        public_send("#{k}=", v)
      end

      @compiler_options  ||= {}
      @default_processor ||= RubyProcessor
      @processors  ||= DEFAULT_PROCESSORS
      @stubs       ||= []
      @preload     ||= []
      @prerequired ||= []
      @path_reader ||= PathReader.new

      @processed = Set.new

      @assets = []
    end

    def self.build(*args, &block)
      new.build(*args, &block)
    end

    def build(logical_path, options = {})
      source = read logical_path
      build_str source, logical_path, options
      self
    end

    def build_str(source, logical_path, options = {})
      filename = path_reader.expand(logical_path).to_s
      asset = processor_for(source, logical_path, filename, requirable: false)

      preload.each { |path| process_require path, options }

      process_requires asset, filename, options
      @assets << asset
      self
    end

    def build_require(logical_path, options = {})
      process_require(logical_path, options)
    end

    def process_require(logical_path, options)
      return if prerequired.include?(logical_path)
      return if processed.include?(logical_path)
      processed << logical_path

      filename = path_reader.expand(logical_path).to_s
      asset = find_asset logical_path

      process_requires asset, filename, options

      @assets << asset
    end

    def process_requires(asset, filename, options)
      (asset.requires + tree_requires(asset, filename)).each do |require_path|
        process_require require_path, options
      end
    end

    def find_asset(logical_path)
      cached_asset(logical_path) do
        source = stub?(logical_path) ? '' : read(logical_path)

        if source.nil?
          message = "can't find file: #{logical_path.inspect}"
          case @compiler_options[:dynamic_require_severity]
          when :error then raise LoadError, message
          when :warning then warn "can't find file: #{logical_path.inspect}"
          end
        end

        filename = path_reader.expand(logical_path).to_s

        asset = processor_for(source, logical_path, filename, requirable: true)
        stat  = stat(logical_path)
        # TODO: fixme - processors should do this
        asset.mtime = stat(logical_path).mtime.to_i if stat

        asset
      end
    end

    def cached_asset(logical_path)
      if cache_store.nil?
        yield
      elsif (asset = cache_store[logical_path]) && asset.fresh?(self, logical_path)
        asset
      else
        asset = yield

        # TODO: cache asset (should check for cache_store first)
        cache_store[logical_path] = asset

        asset
      end
    end

    def to_s
      assets.map(&:to_s).join("\n")
    end

    def source_map
      assets.map(&:source_map).reduce(:+).as_json.to_json
    end

    attr_accessor :processors, :default_processor, :path_reader,
                  :compiler_options, :stubs, :prerequired, :preload




    def tree_requires(asset, filename)
      if filename.nil? or filename.empty?
        dirname = Dir.pwd
      else
        dirname = File.dirname(File.expand_path(filename))
      end

      paths = path_reader.paths.map { |p| File.expand_path(p) }

      asset.required_trees.flat_map do |tree|
        expanded = File.expand_path(tree, dirname)
        base = paths.find { |p| expanded.start_with?(p) }
        next [] if base.nil?

        globs = extensions.map { |ext| File.join base, tree, '**', "*.#{ext}" }

        Dir[*globs].map do |file|
          Pathname(file).relative_path_from(Pathname(base)).to_s.gsub(/(\.js)?(\.(?:#{extensions.join '|'}))$/, '')
        end
      end
    end

    def processor_for(source, logical_path, filename, options)
      processor   = processors.find { |p| p.match? filename }
      processor ||= default_processor
      return processor.new(source, logical_path, compiler_options.merge(options))
    end

    def read(logical_path)
      path_reader.read(logical_path) or
        raise ArgumentError, "can't find file: #{logical_path.inspect} in #{path_reader.paths.inspect}"
    end

    def stat(logical_path)
      path_reader.stat(logical_path)
    end

    def stub?(logical_path)
      stubs.include?(logical_path)
    end

    def extensions
      @extensions ||= DEFAULT_PROCESSORS.flat_map(&:extensions).compact
    end
  end
end
