# frozen_string_literal: true

module Builders
  module Frontends
    class Dockerfile < Base
      def construct_command(repository_path, image_tag)
        docker_build_command = [
          "docker",
          "--context", "default",
          "buildx",
          "build",
          "--progress=plain",
          "--platform", "linux/amd64",
          "-t", image_tag,
          "-f", File.join(repository_path, project.dockerfile_path)
        ]

        # Add environment variables to the build command
        project.environment_variables.each do |envar|
          docker_build_command.push("--build-arg", "#{envar.name}=\"#{envar.value}\"")
        end

        docker_build_command.push("--push")

        # Add the build context directory at the end
        docker_build_command.push(File.join(repository_path, project.docker_build_context_directory))
        docker_build_command
      end
    end
  end
end
