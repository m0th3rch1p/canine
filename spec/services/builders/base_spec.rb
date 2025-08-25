require 'rails_helper'

RSpec.describe Builders::Base do
  let(:build) { create(:build) }
  let(:project) { build.project }
  let(:builder) { described_class.new(build) }

  describe '#initialize' do
    context 'with default configuration' do
      it 'creates dockerfile frontend and docker backend by default' do
        expect(builder.frontend).to be_a(Builders::Frontends::Dockerfile)
        expect(builder.backend).to be_a(Builders::Backends::Docker)
      end
    end

    context 'with buildpack build configuration' do
      before do
        build_config = create(:build_configuration, project: project, build_type: 'buildpack', driver: 'docker')
        allow(project).to receive(:build_configuration).and_return(build_config)
      end

      it 'creates buildpack frontend' do
        builder = described_class.new(build)
        expect(builder.frontend).to be_a(Builders::Frontends::Buildpack)
        expect(builder.backend).to be_a(Builders::Backends::Docker)
      end
    end

    context 'with kubernetes build configuration' do
      before do
        build_config = create(:build_configuration, :kubernetes, project: project)
        allow(project).to receive(:build_configuration).and_return(build_config)
      end

      it 'creates kubernetes backend' do
        builder = described_class.new(build)
        expect(builder.frontend).to be_a(Builders::Frontends::Dockerfile)
        expect(builder.backend).to be_a(Builders::Backends::Kubernetes)
      end
    end

    context 'with explicit frontend and backend' do
      let(:frontend) { double('frontend') }
      let(:backend) { double('backend') }

      it 'uses the provided frontend and backend' do
        builder = described_class.new(build, frontend: frontend, backend: backend)
        expect(builder.frontend).to eq(frontend)
        expect(builder.backend).to eq(backend)
      end
    end
  end

  describe '#build_image' do
    let(:repository_path) { '/tmp/repo' }
    let(:frontend) { double('frontend') }
    let(:backend) { double('backend') }
    let(:command) { ['pack', 'build', 'image:tag'] }

    before do
      allow(frontend).to receive(:prepare)
      allow(frontend).to receive(:construct_command).and_return(command)
      allow(frontend).to receive(:cleanup)
      allow(backend).to receive(:prepare)
      allow(backend).to receive(:execute)
      allow(backend).to receive(:cleanup)
      allow(project).to receive(:container_registry_url).and_return('registry.example.com/my-app:latest')
    end

    it 'orchestrates the build process' do
      builder = described_class.new(build, frontend: frontend, backend: backend)
      
      builder.build_image(repository_path)
      
      expect(frontend).to have_received(:prepare).with(repository_path)
      expect(backend).to have_received(:prepare)
      expect(frontend).to have_received(:construct_command).with(repository_path, 'registry.example.com/my-app:latest')
      expect(backend).to have_received(:execute).with(command)
      expect(frontend).to have_received(:cleanup).with(repository_path)
      expect(backend).to have_received(:cleanup)
    end
  end

  describe '#login_to_registry' do
    let(:project_credential_provider) { double('project_credential_provider') }
    let(:backend) { double('backend') }

    it 'delegates to backend' do
      builder = described_class.new(build, backend: backend)
      allow(backend).to receive(:login_to_registry)
      
      builder.login_to_registry(project_credential_provider)
      
      expect(backend).to have_received(:login_to_registry).with(project_credential_provider)
    end
  end
end