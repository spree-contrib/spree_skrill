class SkrillStatusController < ApplicationController
  def update
    payment_id = params[:transaction_id].split('-').last

    payment = Payment.find(payment_id)

    unless payment.completed?

      case params[:status]
        when "0"
          payment.pend #may already be pending
        when "2" #processed / captured
          payment.complete!
        when "-1", "-2"
          payment.failure!
        else
          raise "Unexpected payment status"
      end

    end

    render :text => ""
  end
end
