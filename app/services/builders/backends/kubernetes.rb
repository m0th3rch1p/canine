# frozen_string_literal: true

require 'open3'

module Builders
  module Backends
    class Kubernetes < Base
      def execute(command)
        # For Kubernetes backend, we need to ensure we're using the buildx builder
        # that's configured for the BuildCloud
        modified_command = modify_command_for_k8s(command)

        runner = Cli::RunAndLog.new(build, killable: build)
        runner.call(modified_command.join(" "))
      rescue Cli::CommandFailedError => e
        raise "Kubernetes build failed: #{e.message}"
      end

      def login_to_registry(project_credential_provider)
        base_url = project_credential_provider.provider.registry_base_url
        docker_login_command = [ "docker", "login", base_url, "--username" ] +
                                [ project_credential_provider.username, "--password", project_credential_provider.access_token ]

        build.info("Logging into #{base_url} as #{project_credential_provider.username}", color: :yellow)
        _stdout, stderr, status = Open3.capture3(*docker_login_command)

        if status.success?
          build.success("Logged in to #{base_url} successfully.")
        else
          build.error("#{base_url} login failed with error:\n#{stderr}")
          raise "Docker login failed: #{stderr}"
        end
      end

      private

      def modify_command_for_k8s(command)
        # If it's a docker buildx command, add the builder name
        if command[0] == "docker" && command.include?("buildx")
          # Find where to insert the builder flag
          buildx_index = command.index("buildx")
          build_index = command.index("build")

          if buildx_index && build_index
            # Insert the builder flag after "build"
            modified = command.dup
            modified.insert(build_index + 1, "--builder", K8::BuildCloudManager::BUILDKIT_BUILDER_NAME)

            # Also update platform support for K8s builder
            if platform_index = modified.index("--platform")
              modified[platform_index + 1] = "linux/amd64,linux/arm64"
            end

            return modified
          end
        elsif command[0] == "pack"
          # For pack commands with Kubernetes, we might need to use a different approach
          # For now, fall back to local Docker daemon
          build.info("Note: Buildpack builds on Kubernetes use local Docker daemon", color: :yellow)
        end

        command
      end
    end
  end
end
