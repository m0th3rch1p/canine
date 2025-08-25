# frozen_string_literal: true

module Builders
  module Frontends
    class Base
      attr_reader :build, :project

      def initialize(build)
        @build = build
        @project = build.project
      end

      # Must be implemented by subclasses to return the build command
      def construct_command(repository_path, image_tag)
        raise NotImplementedError, "Subclasses must implement construct_command"
      end

      # Hook for any frontend-specific preparation
      def prepare(repository_path)
        # Can be overridden by subclasses if needed
      end

      # Hook for any frontend-specific cleanup
      def cleanup(repository_path)
        # Can be overridden by subclasses if needed
      end
    end
  end
end
