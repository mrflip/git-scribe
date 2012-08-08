require 'rubygems' unless defined?(Gem)
require 'nokogiri'
require 'liquid'
require 'yaml'
require 'grit'

require 'git-scribe/generate'
require 'git-scribe/check'
require 'git-scribe/init'

require 'fileutils'
require 'pp'

require 'logger'
Log = Logger.new($stderr).tap{|log| log.level = Logger::WARN } unless defined?(Log)

class GitScribe

  include Init
  include Check
  include Generate

  attr_accessor :subcommand, :args, :options
  attr_reader :info
  attr_reader :repo_dir

  GLOBAL_OPTIONS = {
    'book_file'    => 'book.asc',
    'output_types' => ['docbook', 'html', 'pdf', 'epub', 'mobi', 'site'],
    'verbose'      => false
  }

  SCRIBE_ROOT = File.expand_path('..', File.dirname(File.realpath(__FILE__)))

  def initialize
    @repo_dir   = Dir.pwd
    @subcommand = nil
    @args       = []
    @options    = {}
    @config     = GLOBAL_OPTIONS.merge(dot_gitscribe)
    Log.level   = Logger::DEBUG if verbose?
    Log.debug{ "git-scribe root: #{SCRIBE_ROOT}"   }
    Log.debug{ "configuration: #{@config.inspect}" }
  end

  def dot_gitscribe
    filename = local('.gitscribe')
    YAML::parse(File.open(filename)).transform
  rescue Errno::ENOENT => err
    return {} # file not found -- harmless
  rescue StandardError => err
    warn "Error loading #{filename}: #{err.class} #{err}\n  #{err.backtrace[0..2].join("\n  ")}"
    return {}
  end

  def verbose?
    !! @config['verbose']
  end

  ## COMMANDS ##

  def die(message)
    raise message
  end

  def local(*args)
    File.expand_path(File.join(repo_dir, *args))
  end

  def base(*args)
    File.join(SCRIBE_ROOT, *args)
  end

  # API/DATA HELPER FUNCTIONS #

  def git(subcommand)
    `git #{subcommand}`.chomp
  end

  def first_arg(args)
    Array(args).shift
  end

  # eventually we'll want to log this or have it retrievable elsehow
  def info(message)
    @info ||= []
    puts message
    @info << message
  end

end
