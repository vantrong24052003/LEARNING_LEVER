class ChangeBalanceTypeInWallets < ActiveRecord::Migration[8.0]
  def change
    change_column :wallets, :balance, :integer, default: 0, null: false
  end
end
