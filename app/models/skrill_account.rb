class SkrillAccount < ActiveRecord::Base
  has_many :payments, :as => :source

  def actions
    []
  end
end
