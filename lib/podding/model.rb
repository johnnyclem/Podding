# encoding: utf-8

require 'scrivener'

class Model
  extend Finders
  include Scrivener::Validations

  # Make self.base_path writable
  class << self
    attr_accessor :base_path
  end

  def self.all
    all_files = scan_files

    all_files.map do |path|
      raw_content = File.read(path)
      self.new(path: path, raw_content: raw_content)
    end.sort_by &default_sort_by
  end

  def self.path
    name = to_reference + "s"
    "#{ Model.base_path }/#{ name }"
  end

  def self.scan_files
    files = "#{ path }/**/*.{markdown,md}"
    Dir[files]
  end

  def self.default_sort_by
    :name
  end

  # Manage relations between models

  def self.attribute(name)
    define_method(name) do
      @data[name.to_s]
    end

    attributes << name
  end

  def self.attributes
    @attrs ||= [ ]
  end

  def self.belongs_to(name, model)
    define_method name do
      name = name.to_s
      model = Utils.class_lookup(self.class, model)
      model.first(:name => self.data[name])
    end
  end

  def self.has_many(name, model, reference = to_reference)
    define_method name do
      model = Utils.class_lookup(self.class, model)
      if reference.to_s.end_with?("s")
        model.find_match(:"#{ reference }" => self.name)
      else
        model.find(:"#{ reference }" => self.name)
      end
    end
  end

  def self.to_reference
    self.name.downcase
  end

  attr_reader :content, :data

  attribute :name

  def initialize(opts)
    raise ArgumentError, 'No raw_content given' if opts[:raw_content].nil?


    split_content = split_content_and_meta(opts[:path], opts[:raw_content])
    @content = split_content[:content]
    @data = split_content[:data]
  end

  def attributes
    self.class.attributes
  end

  def split_content_and_meta(path, raw_content)
    content = ''
    data = { }

    begin
      if match = raw_content.match(/^(---\s*\n(.*?)\n?)^(---\s*$\n?)(.*)/m)
        data = YAML.load(match[2])
        content = match[4]
      else
        content = raw_content
      end
    rescue Psych::SyntaxError => e
      raise "YAML error while reading #{ path }: #{ e.message }"
    end

    { content: content, data: data }
  end

  def validate
    assert_present :name
  end

  def template
    if @data["template"]
      @data["template"].to_sym
    else
      default_template
    end
  end

  def default_template
    self.class.name.downcase.to_sym
  end

  def ==(other_model)
    meta_equals = self.data == other_model.data
    content_equals = self.content == other_model.content

    meta_equals && content_equals
  end

end
