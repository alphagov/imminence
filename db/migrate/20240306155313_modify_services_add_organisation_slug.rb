class ModifyServicesAddOrganisationSlug < ActiveRecord::Migration[7.0]
  def change
    add_column :services, :organisation_slugs, :string, array: true, default: []
  end
end
