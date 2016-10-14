require 'rubygems'
require 'net/http'
require 'uri'
require 'json'


class Version < Struct.new(:version)
  include Comparable
  def <=> (other)
    version.split('.').zip(other.split('.')).each do |a, b|
      cmp = a.to_i <=> b.to_i
      next if cmp.zero?
      return cmp
    end
    0
  end
end

class BulkGemInstaller < Struct.new(:name, :min_version)
  def call
    versions.each do |version|
      Gem.install(name, version, document: false)
    end
  end

  def versions
    uri = URI.parse("https://rubygems.org/api/v1/versions/#{name}.json")
    response = Net::HTTP.get_response(uri)
    JSON.load(response.body)
      .select {|h| h['platform'] == 'ruby' }
      .map {|h| h['number'] }
      .reject {|v| v < Version.new(min_version) }
      .reject {|v| /[a-zA-Z]/ =~ v } # reject rc1, beta, etc
  end
end

Gem.post_install do |installer|
  puts "Successfully installed #{installer.spec.full_name}"
end

[
  ['rails', '4.0.0'],
  ['pg', '0.16.0'],
].each do |args|
  BulkGemInstaller.new(*args).call
end
