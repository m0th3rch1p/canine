# frozen_string_literal: true

require 'tempfile'
require 'ostruct'

module Builders
  # Legacy BuildCloud builder for backwards compatibility
  # This now uses the composable architecture internally
  class BuildCloud < Base
    def initialize(build)
      # Force Kubernetes backend with Dockerfile frontend for legacy compatibility
      frontend = Builders::Frontends::Dockerfile.new(build)
      backend = Builders::Backends::Kubernetes.new(build)
      super(build, frontend: frontend, backend: backend)
    end
  end
end
