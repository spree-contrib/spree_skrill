module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class Skrill < Gateway

      def service_url
        "https://www.moneybookers.com/app/payment.pl"
      end

      def session_url(session_id)
        "#{service_url}?sid=#{session_id}"
      end

      def setup_payment_session(opts)
        post = PostData.new
        post.merge! opts

        post[:prepare_only] = true

        ssl_post(service_url, post.to_s)
      end

    end
  end
end
