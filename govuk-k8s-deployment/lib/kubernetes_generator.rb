require 'erb'
require 'fileutils'
require 'pathname'
require 'yaml'
require_relative './cryptutils.rb'

class KubernetesGenerator
  include CryptUtils

  def initialize(datadir, templatedir, application, environment, resource)
    @datadir = datadir
    @templatedir = templatedir
    @application = application
    @environment = environment
    @resource = resource

    @resource_config = Array.new
  end

  def save(outputdir)
    raise "Output directory #{outputdir} does not exist" if ! Dir.exists?(outputdir)

    configure_resource
    @resource_config.each_with_index do |entry, index|
      @config = entry
      File.open(File.join(outputdir, "#{@resource}-#{index}.yaml"), "w") do |file|
        file.write ERB.new(File.read(template), nil, '-').result(binding)
      end
    end
  end
    
  def dump
    configure_resource

    @resource_config.each_with_index do |entry, index|
      @config = entry
      puts ERB.new(File.read(template), nil, '-').result(binding)
    end
  end  

  private

  def validate_data!
    raise("Could not find key for #{@resource} in #{datafile}") if @data.nil?
  end

  def update_data!
  end

  def configure_resource
    @data = YAML.load(File.read(datafile))["#{@application}::#{@resource}"]

    validate_data!
    update_data!

    @resource_config.push(@data).flatten!
  end

  def datafile
    [File.join(@datadir, @application, @environment + '.yaml'),
     File.join(@datadir, @application, 'common.yaml')
    ].each do | file |
      return file if File.file?(file)
    end
    raise("No datafile found in #{datadir}")
  end

  def template
    [File.join(@templatedir, @application, @environment, @resource + '.yaml.erb'),
     File.join(@templatedir, @application, @resource + '.yaml.erb'),
     File.join(@templatedir, 'default', @resource + '.yaml.erb')
    ].each do | file |
      return file if File.file?(file)
    end
    raise("No template found in #{templatedir}")
  end
end

class KubernetesGeneratorNamespace < KubernetesGenerator
  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'namespace')
  end
end

class KubernetesGeneratorConfigmap < KubernetesGenerator
  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'configmap')
  end

  private

  def validate_data!
    super
    raise("Configmap needs to be an array") if !@data.kind_of?(Array)
  end
end

class KubernetesGeneratorSecret < KubernetesGenerator
  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'secret')
  end

  private

  def validate_data!
    super
    raise("Secret needs to be an array") if !@data.kind_of?(Array)
  end

  def update_data!
    @data.each do | secret | 
      secret['data'].each do | key, value |
        eyamltext = value.sub(/^ENC\[GPG,(.*)\]$/, '\1')
        fail "Secret with key #{key} must be encrypted with YAML GPG" if eyamltext.nil?
        plaintext = decrypt_eyaml(eyamltext)
        secret['data'][key] = encrypt_secret(plaintext)
      end
    end
  end
end

class KubernetesGeneratorDeployment < KubernetesGenerator
  attr_accessor :tag

  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'deployment')
  end
end

class KubernetesGeneratorService < KubernetesGenerator
  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'service')
  end
end

class KubernetesGeneratorIngress < KubernetesGenerator
  def initialize(datadir, templatedir, application, environment)
    super(datadir, templatedir, application, environment, 'ingress')
  end
end

