module SpreeSkrill
  class Engine < Rails::Engine
    engine_name 'spree_skrill'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Order.state_machine.states << skrill_state = StateMachine::State.new(Order.state_machine, 'skrill')

      Order.state_machine.events << next_event = StateMachine::Event.new(Order.state_machine, :next)
      next_event.transition :from => 'cart', :to => 'address'
      next_event.transition :from => 'address', :to  => 'delivery'
      next_event.transition :from => 'delivery', :to  => 'payment', :if => :payment_required?
      next_event.transition :from => 'payment', :to  => 'skrill', :if => lambda {true}
      next_event.transition :from => 'skrill', :to  => 'complete'
      next_event.transition :from => 'payment', :to  => 'confirm', :if => Proc.new { Gateway.current && Gateway.current.payment_profiles_supported? }
      next_event.transition :from => 'payment', :to  => 'complete'

      Order.state_machine.before_transition :to => 'skrill', :do => Proc.new{ |order|
        skrill_account = SkrillAccount.find_or_create_by_email(order.email)

        payment = order.payments.create(
          :amount => order.total,
          :source => skrill_account,
          :payment_method => order.payment_method)

        payment.started_processing!
        payment.pend!

      }

      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree_skrill.register.payment_methods" do |app|
      app.config.spree.payment_methods += [
        Spree::BillingIntegration::Skrill::QuickCheckout
      ]
    end


  end
end
