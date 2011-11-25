class CreateSkrillAccounts < ActiveRecord::Migration
  def self.up
    create_table :skrill_accounts do |t|
      t.string :email
      t.timestamps
    end
  end

  def self.down
    drop_table :skrill_accounts
  end 
end
