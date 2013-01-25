Spree::CheckoutController.class_eval do
  unless Rails.application.config.consider_all_requests_local
    rescue_from ::Cielo::PaymentError, :with => :handle_cielo_error
  end

  private
    def handle_cielo_error(e)
      flash[:error] = e.model_errors
      redirect_to checkout_state_path(:payment)
    end
end