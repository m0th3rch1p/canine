# frozen_string_literal: true

require 'open3'

module Builders
  # Legacy Docker builder for backwards compatibility
  # This now uses the composable architecture internally
  class Docker < Base
    def initialize(build)
      # Force Docker backend with Dockerfile frontend for legacy compatibility
      frontend = Builders::Frontends::Dockerfile.new(build)
      backend = Builders::Backends::Docker.new(build)
      super(build, frontend: frontend, backend: backend)
    end
  end
end
