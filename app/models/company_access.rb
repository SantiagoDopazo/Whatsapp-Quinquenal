class CompanyAccess
  def initialize(agent)
    @agent = agent
  end

  def companies
    return Company.none unless @agent

    Company.where(id: @agent.company_id)
  end

  def agents
    return Agent.none unless @agent

    @agent.company.agents
  end

  def contacts
    return Contact.none unless @agent

    @agent.company.contacts
  end

  def conversations
    Conversation.where(contact_id: contacts.select(:id))
  end
end
