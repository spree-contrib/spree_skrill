CheckoutController.class_eval do
  def skrill_cancel
    flash[:error] = t(:payment_has_been_cancelled)
    redirect_to edit_order_checkout_url(@order, :state => 'payment')
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
end
