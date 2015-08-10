# For Bundler.with_clean_env
require 'bundler/setup'
require 'aws-sdk'
require 'yaml'
require_relative 'lib/cloudstats/helpers/object'
require_relative 'lib/cloudstats/config'

PACKAGE_NAME = "cloudstats-agent"
VERSION = Config[:version]
TRAVELING_RUBY_VERSION = "20150210-2.1.5"
OUT_DIR = "out"

s3 = Aws::S3::Resource.new(region: 'eu-west-1')

NATIVES = {
}

desc "Package your app"
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

desc 'Deploy agent'
task :deploy => [:package, 'deploy:installer', 'deploy:version_file'] do
  ['osx', 'linux-x86', 'linux-x86_64'].each do |target|
    package = "#{PACKAGE_NAME}-#{VERSION}-#{target}.tar.gz"
    latest_package = "#{PACKAGE_NAME}-latest-#{target}.tar.gz"

    puts "Uploading #{package}..."
    p azure_upload "#{OUT_DIR}/#{package}", package

    puts "Uploading #{latest_package}..."
    p azure_upload "#{OUT_DIR}/#{package}", latest_package
  end
end

namespace :deploy do
  desc 'Deploy the installer'
  task :installer do
    puts "Uploading installer ..."
    p azure_upload 'installer'
  end

  desc 'Deploy the version file'
  task :version_file do
    puts "Changing version file to v.#{VERSION}"
    File.open('version', 'w') { |f| f.write VERSION }
    p azure_upload 'version'
  end
end

namespace :package do

  def deps(platform)
    [:bundle_install] +
      ["packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{platform}.tar.gz"] +
      NATIVES.map do |name, version|
        "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{platform}-#{name}-#{version}.tar.gz"
      end
  end

  namespace :linux do
    desc "Package your app for Linux x86"
    task :x86 => deps('linux-x86') do
      create_package("linux-x86")
    end

    desc "Package your app for Linux x86_64"
    task :x86_64 => deps('linux-x86_64') do
      create_package("linux-x86_64")
    end
  end

  desc "Package your app for OS X"
  task :osx => deps('osx') do
    create_package("osx")
  end

  desc "Install gems to local directory"
  task :bundle_install do
    if RUBY_VERSION !~ /^2\.1\./
      abort "You can only 'bundle install' using Ruby 2.1, because that's what Traveling Ruby uses."
    end
    sh "rm -rf packaging/tmp"
    sh "mkdir -p packaging/tmp"
    sh "cp Gemfile Gemfile.lock packaging/tmp/"
    Bundler.with_clean_env do
      sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development"
    end
    sh "rm -rf packaging/tmp"
    sh "rm -f packaging/vendor/*/*/cache/*"
    sh "rm -rf packaging/vendor/ruby/*/extensions"
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.o' | xargs rm -f"
  end
end

# RUNTIME

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  download_runtime("linux-x86")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  download_runtime("linux-x86_64")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  download_runtime("osx")
end

# /RUNTIME

# NATIVES

NATIVES.each do |name, version|
  file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-#{name}-#{version}.tar.gz" do
    download_native_extension("linux-x86", "#{name}-#{version}")
  end
  file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-#{name}-#{version}.tar.gz" do
    download_native_extension("linux-x86_64", "#{name}-#{version}")
  end
  file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-#{name}-#{version}.tar.gz" do
    download_native_extension("osx", "#{name}-#{version}")
  end
end

# / NATIVES

# UTILS

def create_package(target)
  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "cp installer #{package_dir}"
  sh "mkdir #{package_dir}/init.d"
  sh "cp init.d/cloudstats-agent #{package_dir}/init.d/"
  sh "mkdir -p #{package_dir}/lib/app"
  sh "cp -r lib #{package_dir}/lib/app/"
  # sh "cp config.yml #{package_dir}/lib/app/"
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"
  sh "cp packaging/wrapper.sh #{package_dir}/#{PACKAGE_NAME}"
  sh "cp packaging/reset-key.sh #{package_dir}/reset-key"
  sh "chmod +x #{package_dir}/#{PACKAGE_NAME}"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"
  sh "cp Gemfile Gemfile.lock #{package_dir}/lib/vendor/"
  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"
  NATIVES.each do |name, version|
    sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{name}-#{version}.tar.gz " +
      "-C #{package_dir}/lib/vendor/ruby"
  end
  if !ENV['DIR_ONLY']
    sh "mkdir -p #{OUT_DIR}"
    sh "tar -czf #{OUT_DIR}/#{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  sh "cd packaging && curl -L -O --fail " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  file = "traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz"
  local = "packaging/precompiled/#{file}"
  if File.exists?(local)
    sh "cp #{local} packaing/#{file}"
  else
    sh "curl -L --fail -o packaging/#{file} http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
  end
end

def azure_upload(local_file, remote_file = nil)
  remote_file ||= local_file

  puts "Uploading the #{local_file} blob..."
  p `azure storage blob upload -q #{local_file} agent #{remote_file}`
end

# / UTILS
