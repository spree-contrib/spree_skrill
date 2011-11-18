class CreateSkrillAccounts < ActiveRecord::Migration
  def change
    create_table :skrill_accounts do |t|
      t.string :email
      t.timestamps
    end
  end
end
