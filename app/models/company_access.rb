class CompanyAccess
  def initialize(agent)
    @agent = agent
  end

  def scope(model)
    return model.none unless @agent

    case model.name
    when "Company" then model.where(id: @agent.company_id)
    when "Agent", "Contact" then model.where(company_id: @agent.company_id)
    when "Conversation" then model.where(contact_id: @agent.company.contacts.select(:id))
    else
      raise ArgumentError, "No company scope for #{model.name}"
    end
  end
end
