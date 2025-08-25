# == Schema Information
#
# Table name: build_configurations
#
#  id             :bigint           not null, primary key
#  build_type     :integer          default(0), not null
#  driver         :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  build_cloud_id :bigint
#  project_id     :bigint           not null
#  provider_id    :bigint           not null
#
# Indexes
#
#  index_build_configurations_on_build_cloud_id  (build_cloud_id)
#  index_build_configurations_on_project_id      (project_id)
#  index_build_configurations_on_provider_id     (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (build_cloud_id => build_clouds.id)
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (provider_id => providers.id)
#
require 'rails_helper'

RSpec.describe BuildConfiguration, type: :model do
  describe 'enums' do
    it 'defines driver enum' do
      expect(described_class.drivers).to eq({ 'docker' => 0, 'k8s' => 1 })
    end

    it 'defines build_type enum' do
      expect(described_class.build_types).to eq({ 'dockerfile' => 0, 'buildpack' => 1 })
    end
  end

  describe 'validations' do
    let(:project) { create(:project) }
    let(:provider) { create(:provider) }

    context 'when driver is k8s' do
      it 'requires build_cloud' do
        build_config = BuildConfiguration.new(
          project: project,
          provider: provider,
          driver: 'k8s',
          build_cloud: nil
        )

        expect(build_config).not_to be_valid
        expect(build_config.errors[:build_cloud]).to include("can't be blank")
      end

      it 'is valid with build_cloud' do
        build_config = build(:build_configuration, :kubernetes, project: project, provider: provider)

        expect(build_config).to be_valid
      end
    end

    context 'when driver is docker' do
      it 'does not require build_cloud' do
        build_config = BuildConfiguration.new(
          project: project,
          provider: provider,
          driver: 'docker',
          build_cloud: nil
        )

        expect(build_config).to be_valid
      end
    end
  end

  describe 'defaults' do
    let(:project) { create(:project) }
    let(:provider) { create(:provider) }

    it 'defaults build_type to dockerfile' do
      build_config = BuildConfiguration.new(
        project: project,
        provider: provider,
        driver: 'docker'
      )

      expect(build_config.build_type).to eq('dockerfile')
    end
  end
end
