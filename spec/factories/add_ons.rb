# == Schema Information
#
# Table name: add_ons
#
#  id         :bigint           not null, primary key
#  chart_type :string           not null
#  chart_url  :string
#  metadata   :jsonb
#  name       :string           not null
#  status     :integer          default("installing"), not null
#  values     :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cluster_id :bigint           not null
#
# Indexes
#
#  index_add_ons_on_cluster_id           (cluster_id)
#  index_add_ons_on_cluster_id_and_name  (cluster_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cluster_id => clusters.id)
#
FactoryBot.define do
  factory :add_on do
    cluster
    chart_url { 'bitnami/redis' }
    chart_type { "helm_chart" }
    sequence(:name) { |n| "example-addon-#{n}" }
    status { :installing }
    values { {} }
    metadata { { "package_details" => { "repository" => { "name" => "bitnami", "url" => "https://bitnami.com/charts" } } } }
  end
end
