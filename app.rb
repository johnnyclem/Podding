#!/usr/bin/env ruby
# encoding: utf-8

if "1.9".respond_to?(:encoding)
  Encoding.default_external = 'UTF-8'
  Encoding.default_internal = 'UTF-8'
end

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/assetpack'
require 'sinatra/config_file'
require 'slim'
require 'less'
require 'redcarpet'
require 'net/http'
require 'net/https'
require 'json'
require 'i18n'

require 'mlk'
require 'mlk/storage_engines/file_storage'

require_relative 'lib/podding'

class Podding < Sinatra::Base
  register Sinatra::ConfigFile

  enable :sessions, :static, :logging

  source_dir = File.dirname(__FILE__) + '/source'
  config_file "#{ source_dir }/config.yaml"

  set :root, File.dirname(__FILE__)
  register Sinatra::AssetPack

  set :public_folder, source_dir + '/assets'
  set :views, source_dir + '/templates'

  Mlk::FileStorage.base_path = source_dir
  Mlk::Model.storage_engine = Mlk::FileStorage

  configure :production do
    # ...
  end

  configure :development do
    require 'pry'
    require 'pry-byebug'
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  require_relative 'controllers/init'
  require_relative 'models/init'
  require_relative 'helpers/init'
  require_relative 'filters/init'

  Less.paths << source_dir + "/css"

  assets do
    serve '/js',     from: 'source/javascript'
    serve '/css',    from: 'source/css'
    serve '/images', from: 'source/assets/images'
  end

  # Configure localisation

  I18n.load_path += Dir[File.join(source_dir, 'locales', '*.yml').to_s]
  if Settings["language"]
    I18n.locale = Settings.language
  else
    I18n.locale = "en"
  end

  # Load all helpers

  Helper.defined_helpers.each do |helper|
    helpers helper
  end

  run! if app_file == $0
end

