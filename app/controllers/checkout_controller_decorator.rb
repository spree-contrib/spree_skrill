CheckoutController.class_eval do
  before_filter :redirect_to_skrill_if_needed, :only => [:update]
  skip_before_filter :load_order, :only => [:skrill_success]
  skip_before_filter :check_authorization, :only => [:skrill_success]

  def skrill_cancel
    flash[:error] = t(:payment_has_been_cancelled)
    redirect_to edit_order_path(@order)
  end

  def skrill_success
    @order = Order.where(:number => params[:order_id]).first

    if @order.token == params[:token]

      if @order.payments.where(:source_type => 'SkrillAccount').present?

        #need to force checkout to complete state
        until @order.state == "complete"
          if @order.next!
            @order.update!
            state_callback(:after)
          end
        end
      end

      flash.notice = t(:order_processed_successfully)
      redirect_to completion_route
    else
      redirect_to root_url
    end

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
        opts[:transaction_id] = "#{@order.number}-#{payment.id}"
        opts[:amount] = payment.amount
        opts[:return_url] = skrill_success_order_checkout_url(@order, :token => @order.token)
        opts[:cancel_url] = skrill_cancel_order_checkout_url(@order, :token => @order.token)
        opts[:status_url] = skrill_status_update_url

        payment.started_processing!
        payment.pend!

        begin
          redirect_to payment_method.redirect_url(@order, opts)
        rescue Exception => e
          flash.notice = t(:unable_to_redirect_to_skrill)
          redirect_to edit_order_checkout_url(@order, :state => 'payment')
        end
      end
    end

end
