
require 'logger'

module Murk

  DEFAULT_OPTIONS = {
    template_path: ENV['MURK_PATH'] || '',
    stack_prefix: ENV['MURK_PREFIX']
  }

  def self.configure(options = {})
    @options = self.options.merge(options)
  end

  def self.options
    @options ||= DEFAULT_OPTIONS
  end

  def self.load(file)
    self.config_file = file
    config = File.read(config_file)
    builder = Murk::Builder::MurkBuilder.new
    builder.instance_eval(config)
    builder.build
  end

  # rubocop:disable Style/ClassVars
  def self.logger
    @@logger ||= Logger.new(STDOUT).tap do |log|
      log.level = Logger::INFO
      log.progname = 'Murk'
    end
  end

  def self.logger=(logger)
    @@logger = logger.tap do |log|
      log.progname = 'Murk'
    end
  end

  def self.config_file
    @@config_file ||= File.absolute_path('./config')
  end

  def self.config_file=(config_file)
    @@config_file = config_file
  end
  # rubocop:ensable Style/ClassVars

  def self.config_dir
    File.dirname(config_file)
  end

  def logger
    Murk.logger
  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'murk', '**/*.rb')).each { |file| require file }
