CheckoutController.class_eval do
  before_filter :redirect_to_skrill_if_needed, :only => [:update]


  def skrill_return
    #need to force checkout to complete state
    until @order.state == "complete"
      if @order.next!
        @order.update!
        state_callback(:after)
      end
    end

    redirect_to completion_route
  end

  private

    def redirect_to_skrill_if_needed
      return unless (params[:state] == "payment")
      return unless params[:order][:payments_attributes]

      if params[:order][:coupon_code]
        @order.update_attributes(object_params)
        @order.process_coupon_code
      end

      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])

      if payment_method.kind_of?(BillingIntegration::Skrill::QuickCheckout)
        skrill_account = SkrillAccount.find_or_create_by_email(@order.email)

        payment = @order.payments.create(
          :amount => @order.total,
          :source => skrill_account,
          :payment_method => payment_method)

        opts = {}
        opts[:transaction_id] = payment.id
        opts[:amount] = payment.amount
        opts[:return_url] = skrill_return_order_checkout_url(@order)
        opts[:status_url] = skrill_status_update_url
        opts[:cancel_url] = order_url(@order)

        payment.started_processing!
        payment.pend!

        redirect_to payment_method.redirect_url(@order, opts)
      end
    end

end
