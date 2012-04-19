Spree::BaseHelper.class_eval do
  def yaml(obj)
    YAML.load(obj)
  end
  
  def cielo_status(status)
    Cielo::Transaction::Base::STATUSES.key(status).to_s.capitalize
  end
end