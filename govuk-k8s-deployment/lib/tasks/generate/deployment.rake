require_relative '../../configuration.rb'
require_relative '../../kubernetes_generator.rb'

include Configuration

namespace :generate do
  desc "Generate Kubernetes Deployment"
  task :deployment do
    generator = KubernetesGeneratorDeployment.new(datadir, templatedir, application, environment)
    generator.tag = tag
    generator.save(outputdir)
  end
end

