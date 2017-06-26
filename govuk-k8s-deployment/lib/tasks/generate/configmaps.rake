require_relative '../../configuration.rb'
require_relative '../../kubernetes_generator.rb'

include Configuration

namespace :generate do
  task :configmaps do
    KubernetesGeneratorConfigmap.new(datadir, templatedir, application, environment).save(outputdir)
  end
end

