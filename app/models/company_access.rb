class CompanyAccess
  def initialize(agent)
    @agent = agent
  end

  def scope(model)
    return model.none unless @agent

    case model.name
    when "Company" then model.where(id: @agent.company_id)
    when "Agent", "Contact", "WhatsappAccount" then model.where(company_id: @agent.company_id)
    when "PhoneNumber" then model.where(id: @agent.accessible_phone_numbers.select(:id))
    when "PhoneNumberAccess" then model.where(phone_number_id: @agent.accessible_phone_numbers.select(:id))
    when "Conversation"
      conversations = model.where(contact_id: @agent.company.contacts.select(:id))
      @agent.role == "admin" ? conversations : conversations.where(phone_number_id: @agent.accessible_phone_numbers.select(:id))
    when "Message" then model.where(conversation_id: scope(Conversation).select(:id))
    else
      raise ArgumentError, "No company scope for #{model.name}"
    end
  end
end
