class Avo::CompanyResourcesController < Avo::ResourcesController
  private

  def fill_record
    super
    if @record.is_a?(Agent) || @record.is_a?(Contact)
      @record.company = current_agent.company
    end
  end
end
