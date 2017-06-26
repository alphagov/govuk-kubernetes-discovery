module Configuration
  def gnupghome
    ENV['GNUPGHOME'] || ENV['HOME']+"/.gnupg"
  end

  def application
    ENV['APPLICATION'] || raise("APPLICATION is empty")
  end

  def environment
    ENV['ENVIRONMENT'] || raise("ENVIRONMENT is empty")
  end

  def tag
    ENV['TAG'] || 'latest'
  end

  def templatedir
    'templates'
  end

  def datadir
    'data'
  end

  def outputdir
    ENV['OUTPUTDIR'] || "./"
  end
end
