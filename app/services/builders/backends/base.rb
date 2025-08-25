# frozen_string_literal: true

module Builders
  module Backends
    class Base
      attr_reader :build, :project

      def initialize(build)
        @build = build
        @project = build.project
      end

      # Execute the build command on the backend infrastructure
      def execute(command)
        raise NotImplementedError, "Subclasses must implement execute"
      end

      # Login to the container registry
      def login_to_registry(project_credential_provider)
        raise NotImplementedError, "Subclasses must implement login_to_registry"
      end

      # Backend-specific preparation
      def prepare
        # Can be overridden by subclasses
      end

      # Backend-specific cleanup
      def cleanup
        # Can be overridden by subclasses
      end
    end
  end
end
