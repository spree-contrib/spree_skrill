require 'active_merchant/billing/skrill'

class BillingIntegration::Skrill::QuickCheckout < BillingIntegration
  preference :merchant_id, :string
  preference :language, :string, :default => 'EN'
  preference :currency, :string, :default => 'EUR'

  def provider_class
    ActiveMerchant::Billing::Skrill
  end

  def redirect_url(order, opts = {})
    opts.merge! self.preferences

    set_global_options(opts)

    opts[:detail1_text] = order.number
    opts[:detail1_description] = 'Order Number:'

    opts[:pay_from_email] = order.email
    opts[:firstname] = order.bill_address.firstname
    opts[:lastname] = order.bill_address.lastname
    opts[:address] = order.bill_address.address1
    opts[:address2] = order.bill_address.address2
    opts[:phone_number] = order.bill_address.phone
    opts[:city] = order.bill_address.city
    opts[:postal_code] = order.bill_address.zipcode
    opts[:state] = order.bill_address.state.nil? ? order.bill_address.state_name.to_s : order.bill_address.state.abbr
    opts[:country] = order.bill_address.country.name

    skrill = self.provider
    sid = skrill.setup_payment_session(opts)
    puts opts

    skrill.session_url(sid)
  end

  private
    def set_global_options(opts)
      opts[:recipient_description] = Spree::Config[:site_name]
    end

end


