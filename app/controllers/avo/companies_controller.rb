class Avo::CompaniesController < Avo::ResourcesController
  before_action :prevent_company_lifecycle_changes

  private

  def prevent_company_lifecycle_changes
    head :forbidden if action_name.in?(%w[new create destroy])
  end
end
