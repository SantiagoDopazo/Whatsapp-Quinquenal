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

  def whatsapp_accounts
    return WhatsappAccount.none unless @agent

    @agent.company.whatsapp_accounts
  end

  def phone_numbers
    return PhoneNumber.none unless @agent

    @agent.accessible_phone_numbers
  end

  def phone_number_accesses
    PhoneNumberAccess.where(phone_number_id: phone_numbers.select(:id))
  end

  def conversations
    conversations = Conversation.where(contact_id: contacts.select(:id))
    return conversations if @agent&.role == "admin"

    conversations.where(phone_number_id: phone_numbers.select(:id))
  end

  def messages
    Message.where(conversation_id: conversations.select(:id))
  end
end
