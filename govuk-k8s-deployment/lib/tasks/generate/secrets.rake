require_relative '../../configuration.rb'
require_relative '../../kubernetes_generator.rb'

include Configuration

namespace :generate do
  desc "Generate Kubernetes Deployment Secret"
  task :secrets do
    KubernetesGeneratorSecret.new(datadir, templatedir, application, environment).save(outputdir)
  end
end

