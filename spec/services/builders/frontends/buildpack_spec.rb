require 'rails_helper'

RSpec.describe Builders::Frontends::Buildpack do
  let(:build) { create(:build) }
  let(:project) { build.project }
  let(:buildpack) { described_class.new(build) }

  describe '#construct_command' do
    let(:repository_path) { '/tmp/repo' }
    let(:image_tag) { 'registry.example.com/my-app:latest' }

    it 'constructs a pack build command' do
      command = buildpack.construct_command(repository_path, image_tag)
      
      expect(command).to include('pack')
      expect(command).to include('build')
      expect(command).to include(image_tag)
      expect(command).to include('--path', repository_path)
      expect(command).to include('--builder', 'heroku/builder:22')
      expect(command).to include('--publish')
    end

    context 'with environment variables' do
      before do
        create(:environment_variable, project: project, name: 'NODE_ENV', value: 'production')
        create(:environment_variable, project: project, name: 'API_KEY', value: 'secret123')
      end

      it 'includes environment variables in the command' do
        command = buildpack.construct_command(repository_path, image_tag)
        
        expect(command).to include('--env', 'NODE_ENV=production')
        expect(command).to include('--env', 'API_KEY=secret123')
      end
    end
  end

  describe '#prepare' do
    it 'does not raise an error' do
      expect { buildpack.prepare('/tmp/repo') }.not_to raise_error
    end
  end

  describe '#cleanup' do
    it 'does not raise an error' do
      expect { buildpack.cleanup('/tmp/repo') }.not_to raise_error
    end
  end
end