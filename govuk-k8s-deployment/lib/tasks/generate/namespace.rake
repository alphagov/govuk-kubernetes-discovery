require_relative '../../configuration.rb'
require_relative '../../kubernetes_generator.rb'

include Configuration

namespace :generate do
  desc "Generate Kubernetes Namespace"
  task :namespace do
    KubernetesGeneratorNamespace.new(datadir, templatedir, application, environment).save(outputdir)
  end
end

