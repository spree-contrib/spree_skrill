class SkrillStatusController < ApplicationController
  def update
    payment = Payment.find(params[:transaction_id])

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
