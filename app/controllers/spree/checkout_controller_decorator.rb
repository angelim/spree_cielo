
Spree::CheckoutController.class_eval do
  unless Rails.application.config.consider_all_requests_local
    rescue_from ::Cielo::PaymentError, :with => :handle_cielo_error
  end

  def update
    if @order.update_attributes(object_params)

      fire_event('spree.checkout.update')

      if @order.coupon_code.present?

        if Spree::Promotion.exists?(:code => @order.coupon_code)
          fire_event('spree.checkout.coupon_code_added', :coupon_code => @order.coupon_code)
          # If it doesn't exist, raise an error!
          # Giving them another chance to enter a valid coupon code
        else
          flash[:error] = t(:promotion_not_found)
          render :edit and return
        end
      end

      if @order.next
        state_callback(:after)
      else
        flash[:error] = t(:payment_processing_failed)
        respond_with(@order, :location => checkout_state_path(@order.state))
        return
      end
      if @order.state == "complete" && @order.payment_method.class == Spree::PaymentMethod::CieloRegularMethod && !@order.paid?
        redirect_to @order.payment.source.authentication_url
      elsif @order.state == 'complete' || @order.completed?
        flash.notice = t(:order_processed_successfully)
        flash[:commerce_tracking] = 'nothing special'
        respond_with(@order, :location => completion_route)
      else
        respond_with(@order, :location => checkout_state_path(@order.state))
      end
    else
      respond_with(@order) { |format| format.html { render :edit } }
    end
  end

  private
    def handle_cielo_error(e)
      flash[:error] = e.model_errors
      redirect_to checkout_state_path(:payment)
    end
end