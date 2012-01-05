module Spree
  CheckoutController.class_eval do
    before_filter :confirm_skrill, :only => [:update]

    def skrill_return
      if @order.payments.where(:source_type => 'Spree::SkrillTransaction').present?
          #need to force checkout to complete state
          until @order.state == "complete"
            if @order.next!
              @order.update!
              state_callback(:after)
            end
          end
          flash.notice = t(:order_processed_successfully)
          redirect_to completion_route
      else
        redirect_to root_url
      end
    end

    def skrill_cancel
      flash[:error] = t(:payment_has_been_cancelled)
      redirect_to edit_order_path(@order)
    end

    private
    def confirm_skrill
      return unless (params[:state] == "payment") && params[:order][:payments_attributes]

      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      if payment_method.kind_of?(BillingIntegration::Skrill::QuickCheckout)
        #TODO confirming payment method
        redirect_to edit_order_checkout_url(@order, :state => 'payment'),
                    :notice => t(:complete_skrill_checkout)
      end
    end

  end
end
