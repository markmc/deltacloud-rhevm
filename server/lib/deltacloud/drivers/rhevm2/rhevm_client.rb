require 'rubygems'

#gem 'rest-client'

require 'base64'
require 'logger'
require 'restclient'
require 'nokogiri'

module RHEVM

  class Client
    attr_reader :base_uri
    attr_reader :entry_points
    attr_reader :logger

    def initialize(username, password, base_uri, opts={})
      @logger = opts[:verbose] ? Logger.new(STDERR) : []
      @username, @password = username, password
      URI.parse(base_uri)
      @base_uri = base_uri
      @entry_points = {}
      discover_entry_points()
    end

    def storagedomains()
      sds = []
      doc = Nokogiri::XML(get(@entry_points['storagedomains']))
      doc.xpath('storage_domains/storage_domain').each() do |sd|
        sds << StorageDomain.new(self, sd)
      end
      sds
    end

    def storagedomain(href)
      StorageDomain.new(self, Nokogiri::XML(get(href)).xpath('storage_domain')[0])
    end

    def vms()
      vms = []
      doc = Nokogiri::XML(get(@entry_points['vms']))
      doc.xpath('vms/vm').each() do |vm|
        vms << VM.new(self, vm)
      end
      vms
    end

    def vm(href)
      VM.new(self, Nokogiri::XML(get(href)).xpath('vm')[0])
    end

    protected

    def get(uri)
      headers = {
        :authorization => "Basic " + Base64.encode64("#{@username}:#{@password}"),
        :accept => "application/xml"
      }
      @logger << "GET #{uri}\n"
      RestClient.get(uri, headers).to_s()
    end

    def discover_entry_points()
      return if @discovered
      doc = Nokogiri.XML(get(@base_uri))
      doc.xpath('api/link').each() do |link|
        @entry_points[link['rel']] = @base_uri + link['href']
      end
      @discovered = true
    end

  end

  class BaseModel
    attr_accessor(:id, :href, :name)

    def initialize(client, xml)
      client.logger << "#{xml}\n"
      @client = client
      @id = xml[:id]
      @href = @client.base_uri + xml[:href]
      @name = xml.xpath('name').text
    end
  end

  class StorageDomain < BaseModel
    attr_accessor(:type, :status, :master, :storage_type, :address, :path, :host)

    def initialize(client, xml)
      super(client, xml)
      @type = xml.xpath('type').text
      @status = xml.xpath('master').text
      @storage_type = xml.xpath('storage/type')
      @address = xml.xpath('storage/address').text
      @path = xml.xpath('storage/path').text
      @host = xml.xpath('host')[:id]
    end
  end

  class VM < BaseModel
    attr_accessor(:status, :memory, :sockets, :cores, :bootdevs, :host, :cluster, :template, :vmpool)

    def initialize(client, xml)
      super(client, xml)
      @status = xml.xpath('status').text
      @memory = xml.xpath('memory').text
      @sockets = xml.xpath('cpu/topology')[:sockets]
      @cores = xml.xpath('cpu/topology')[:cores]
      @bootdevs = []
      xml.xpath('os/boot').each do |boot|
        @bootdevs << boot[:dev]
      end
      @host = xml.xpath('host')[:id]
      @cluster = xml.xpath('cluster')[:id]
      @template = xml.xpath('template')[:id]
      @vmpool = xml.xpath('vmpool')[:id]
    end
  end

end

#opts = {:verbose => true}

#client = RHEVM::Client.new('me', 'foo', 'http://localhost:8099/rhevm-api-mock/', opts)

#puts client.entry_points.inspect()
#client.vms().each() do |vm|
#  puts client.vm(vm.href.to_s).inspect()
#end
#client.storagedomains().each() do |sd|
#  puts client.storagedomain(sd.href.to_s).inspect()
#end
