class AddBuildTypeToBuildConfigurations < ActiveRecord::Migration[7.2]
  def change
    add_column :build_configurations, :build_type, :integer, default: 0, null: false
  end
end
