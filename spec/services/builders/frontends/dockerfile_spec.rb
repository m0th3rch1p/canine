require 'rails_helper'

RSpec.describe Builders::Frontends::Dockerfile do
  let(:build) { create(:build) }
  let(:project) { build.project }
  let(:dockerfile) { described_class.new(build) }

  describe '#construct_command' do
    let(:repository_path) { '/tmp/repo' }
    let(:image_tag) { 'registry.example.com/my-app:latest' }

    before do
      allow(project).to receive(:dockerfile_path).and_return('Dockerfile')
      allow(project).to receive(:docker_build_context_directory).and_return('.')
    end

    it 'constructs a docker buildx command' do
      command = dockerfile.construct_command(repository_path, image_tag)
      
      expect(command).to include('docker')
      expect(command).to include('--context', 'default')
      expect(command).to include('buildx')
      expect(command).to include('build')
      expect(command).to include('--progress=plain')
      expect(command).to include('--platform', 'linux/amd64')
      expect(command).to include('-t', image_tag)
      expect(command).to include('-f', '/tmp/repo/Dockerfile')
      expect(command).to include('--push')
      expect(command.last).to eq('/tmp/repo/.')
    end

    context 'with environment variables' do
      before do
        create(:environment_variable, project: project, name: 'NODE_ENV', value: 'production')
        create(:environment_variable, project: project, name: 'API_KEY', value: 'secret123')
      end

      it 'includes build arguments in the command' do
        command = dockerfile.construct_command(repository_path, image_tag)
        
        expect(command).to include('--build-arg', 'NODE_ENV="production"')
        expect(command).to include('--build-arg', 'API_KEY="secret123"')
      end
    end
  end

  describe '#prepare' do
    it 'does not raise an error' do
      expect { dockerfile.prepare('/tmp/repo') }.not_to raise_error
    end
  end

  describe '#cleanup' do
    it 'does not raise an error' do
      expect { dockerfile.cleanup('/tmp/repo') }.not_to raise_error
    end
  end
end