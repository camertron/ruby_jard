# frozen_string_literal: true

module RubyJard
  ##
  # Another reinvent-the-wheel configuration
  class Config
    class << self
      def smart_load
        config = RubyJard::Config.new

        unless ENV['JARD_CONFIG_FILE'].nil?
          unless File.exist?(ENV['JARD_CONFIG_FILE'])
            raise "Config file '#{ENV['JARD_CONFIG_FILE']}' does not exist"
          end

          return load_config(config, ENV['JARD_CONFIG_FILE'])
        end

        path = File.expand_path(File.join(Dir.pwd, CONFIG_FILE_NAME))
        load_config(config, path) if File.exist?(path)

        path = File.expand_path(File.join('~/', CONFIG_FILE_NAME))
        load_config(config, path) if File.exist?(path)

        config
      end

      private

      def load_config(config, path)
        config_content = File.read(path)
        config.instance_eval(config_content)

        config
      rescue SyntaxError, StandardError => e
        # Fallback to default setting
        raise "Fail to load jard configurations at #{path}. Error: #{e}"
      end
    end

    attr_accessor :color_scheme, :alias_to_debugger, :layout
    attr_reader :enabled_screens, :filter_version, :filter, :filter_included, :filter_excluded

    CONFIG_FILE_NAME = '.jardrc'
    DEFAULTS = [
      DEFAULT_COLOR_SCHEME = '256',
      DEFAULT_ALIAS_TO_DEBUGGER = false,
      DEFAULT_LAYOUT = nil, # Pick layout automatically
      DEFAULT_FILTER = RubyJard::PathFilter::FILTER_APPLICATION,
      DEFAULT_FILTER_INCLUDED = [].freeze,
      DEFAULT_FILTER_EXCLUDED = [].freeze
    ].freeze

    def initialize
      @filter_version = 0

      @filter = DEFAULT_FILTER
      @filter_included = DEFAULT_FILTER_INCLUDED.dup.freeze
      @filter_excluded = DEFAULT_FILTER_EXCLUDED.dup.freeze

      @color_scheme = DEFAULT_COLOR_SCHEME.freeze
      @alias_to_debugger = DEFAULT_ALIAS_TO_DEBUGGER.freeze
      @layout = DEFAULT_LAYOUT.freeze
      @enabled_screens = RubyJard::Screens.names.dup.freeze
    end

    def config
      self
    end

    def enabled_screens=(input)
      @enabled_screens = input.freeze
    end

    def filter=(input)
      @filter_version += 1
      @filter = input.freeze
    end

    def filter_excluded=(input)
      @filter_version += 1
      @filter_excluded = input.freeze
    end

    def filter_included=(input)
      @filter_version += 1
      @filter_included = input.freeze
    end
  end
end
