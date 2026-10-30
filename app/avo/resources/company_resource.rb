class Avo::Resources::CompanyResource < Avo::BaseResource
  abstract_resource!

  def self.query_scope
    CompanyAccess.new(Avo::Current.user).scope(model_class)
  end

  def self.find_scope
    query_scope
  end
end
