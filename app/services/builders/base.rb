class Builders::Base
  attr_reader :build, :frontend, :backend

  def initialize(build, frontend: nil, backend: nil)
    @build = build
    @frontend = frontend || determine_frontend
    @backend = backend || determine_backend
  end

  def project
    build.project
  end

  # Build and push the image
  def build_image(repository_path)
    # Prepare the build
    frontend.prepare(repository_path)
    backend.prepare

    # Construct the build command
    command = frontend.construct_command(repository_path, project.container_registry_url)

    # Execute the build on the backend
    backend.execute(command)

    # Cleanup
    frontend.cleanup(repository_path)
    backend.cleanup
  end

  # Login to the registry via the backend
  def login_to_registry(project_credential_provider)
    backend.login_to_registry(project_credential_provider)
  end

  private

  def determine_frontend
    build_config = project.build_configuration

    if build_config&.buildpack?
      Builders::Frontends::Buildpack.new(build)
    else
      Builders::Frontends::Dockerfile.new(build)
    end
  end

  def determine_backend
    build_config = project.build_configuration

    if build_config&.k8s?
      build.info("Driver: Kubernetes (#{build_config.build_cloud.friendly_name})", color: :green)
      Builders::Backends::Kubernetes.new(build)
    else
      build.info("Driver: Docker", color: :green)
      Builders::Backends::Docker.new(build)
    end
  end
end
