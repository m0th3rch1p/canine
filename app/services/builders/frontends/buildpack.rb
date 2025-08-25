# frozen_string_literal: true

module Builders
  module Frontends
    class Buildpack < Base
      def construct_command(repository_path, image_tag)
        buildpack_command = [
          "pack",
          "build",
          image_tag,
          "--path", repository_path,
          "--builder", detect_builder,
          "--publish"
        ]

        # Add environment variables as build-time environment variables
        project.environment_variables.each do |envar|
          buildpack_command.push("--env", "#{envar.name}=#{envar.value}")
        end

        buildpack_command
      end

      private

      def detect_builder
        # Default to Heroku builder, but this can be made configurable later
        # Other options: gcr.io/buildpacks/builder:v1, paketobuildpacks/builder:base
        "heroku/builder:22"
      end
    end
  end
end
