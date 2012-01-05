Deface::Override.new(:virtual_path => 'spree/orders/show',
                     :name => 'add_skrill_status_to_order_show',
                     :insert_before => "code[erb-loud]:contains('shared/order_details')",
                     :partial => 'spree/shared/skrill_status')
