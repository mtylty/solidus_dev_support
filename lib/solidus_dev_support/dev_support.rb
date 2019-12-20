# frozen_string_literal: true

unless defined?(Spree::InstallGenerator)
  require 'generators/spree/install/install_generator'
end

require 'generators/spree/dev/dev_generator'

desc "Generates a development app"
namespace :extension do
  task :dev_app, :user_class do |_t, args|
    args.with_defaults(user_class: "Spree::LegacyUser")
    require ENV['LIB_NAME']

    ENV["RAILS_ENV"] = 'test'

    Spree::DevGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--quiet"]
    Spree::InstallGenerator.start ["--lib_name=#{ENV['LIB_NAME']}", "--auto-accept", "--migrate=false", "--seed=false", "--sample=false", "--quiet", "--user_class=#{args[:user_class]}"]

    puts "Setting up development database..."

    sh "bin/rails db:environment:set RAILS_ENV=development"
    sh "bin/rails db:drop db:create db:migrate VERBOSE=true"

    begin
      require "generators/#{ENV['LIB_NAME']}/install/install_generator"
      puts 'Running extension installation generator...'
      "#{ENV['LIB_NAMESPACE'] || ENV['LIB_NAME'].camelize}::Generators::InstallGenerator".constantize.start(["--auto-run-migrations"])
    rescue LoadError
      # No extension generator to run
    end
  end

  task :seed do |_t, _args|
    puts "Seeding ..."

    sh "bundle exec rake db:seed RAILS_ENV=test"
  end

  namespace :dev_app do
    desc "Start development app services"
    task :server do
      sh "bin/rails server"
    end
  end
end
