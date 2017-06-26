require 'fileutils'
require 'io/console'
require 'tmpdir'

desc "Hiera eYAML GPG"
namespace :eyaml do
  desc "Import GPG keys from environment recipients file"
  task :gpg_import, [:application, :environment] do |t, args|
    is_valid_environment?(args.environment)
    recipients_path = build_recipients_path(args.environment)
    last_updated_flag_path = build_last_updated_path(args.environment)

    import = true
    if File.exists?(last_updated_flag_path) and File.mtime(recipients_path) <= File.mtime(last_updated_flag_path)
      puts "#{recipients_path} is older than #{last_updated_flag_path}, skipping import"
      import = false
    end

    if import
      print "Importing GPG keys for #{args.environment} users...\r"

      File.readlines(recipients_path).each do |line|
        key = line.split(' ')[0]
        system("gpg2 --quiet --recv-keys #{key}")
      end

      FileUtils.touch(last_updated_flag_path)
    end
  end

  desc "Edit an encrypted hieradata file"
  task :edit, [:application,:environment] do |t, args|
    Rake.application.invoke_task("eyaml:modify[edit, #{args.application}, #{args.environment}]")
  end

  desc "Decrypt an encrypted hieradata file"
  task :decrypt, [:application,:environment] do |t, args|
    Rake.application.invoke_task("eyaml:modify[decrypt, #{args.application}, #{args.environment}]")
  end

  desc "Recrypt an encrypted hieradata file to add or remove people"
  task :recrypt, [:application,:environment] do |t, args|
    puts 'Before you continue, please review and merge all open pull requests that modify encrypted hieradata'
    puts "Press enter once there aren't any open pull requests..."

    input = STDIN.gets.strip

    if input.empty?
      Rake.application.invoke_task("eyaml:modify[recrypt, #{args.application}, #{args.environment}]")
    end
  end

  task :modify, [:action, :application, :environment] => :gpg_import do |t, args|
    has_action?(args.action)
    is_valid_environment?(args.environment)

    yaml_path = build_yaml_path(args.application, args.environment)
    recipients = build_comma_separated_recipients(args.environment)

    if args.action == 'decrypt'
      decrypt_source_flag = '--eyaml'
    else
      decrypt_source_flag = ''
    end

    command = build_command(args.action, recipients, decrypt_source_flag, yaml_path)

    exec(command)
  end

  def has_action?(action)
    if action.nil?
      raise "Please sepcify an action to pass to Hiera eYAML, i.e. 'edit'"
    end
  end

  def is_valid_environment?(environment)
    if environment.nil?
      raise "Please specify an environment when running this Rake task"
    end

    known_environments = %w{vagrant development training integration staging production}

    if !known_environments.include?(environment)
      raise "Not a known environment. Known environments include:\n" + known_environments.join(', ')
    end
  end

  def prepare_gpg_home!(gpg_path)
    if Dir.glob(File.join(gpg_path, '*.gpg')).any?
      raise "Directory #{gpg_path} already has a GPG keyring. If you wish to create new keys, please delete the existing keypair."
    end

    mkdir_p(gpg_path)
    chmod(0700, gpg_path)
  end

  def build_yaml_path(application, environment)
    if environment == 'vagrant'
      return File.join(build_puppet_repo_path, 'hieradata', "#{environment}_credentials.yaml")
    end

    File.join('data', application, "#{environment}.yaml")
  end

  def build_comma_separated_recipients(environment)
    recipients_file = build_recipients_path(environment)
    recipients = File.read(recipients_file)

    keys = []

    recipients.split("\n").each do |recipient|
      keys << recipient.split('#')[0].strip
    end

    return keys.join(',')
  end

  def build_recipients_path(environment)
    if environment == 'vagrant'
      return File.join(recipients_path_dir(environment), "#{environment}_hiera_gpg.rcp")
    end

    if environment == 'staging'
      recipients_filename = 'production'
    else
      recipients_filename = environment
    end

    File.join(recipients_path_dir(environment), "#{recipients_filename}_hiera_gpg.rcp")
  end

  def build_last_updated_path(environment)
    File.join(recipients_path_dir(environment), ".#{environment}_last_updated")
  end

  def recipients_path_dir(environment)
    if environment == 'vagrant'
      return File.expand_path(File.join(build_puppet_repo_path, 'gpg_recipients'))
    end

    return 'gpg_recipients'
  end

  def build_command(action, comma_separated_recipients, decrypt_source_flag, yaml_path)
    command = %W(
      eyaml
      #{action}
      -n gpg2
      --gpg-always-trust
      --gpg-recipients #{comma_separated_recipients}
      #{decrypt_source_flag}
      #{yaml_path}
    )
    return command.join(' ')
  end
end



