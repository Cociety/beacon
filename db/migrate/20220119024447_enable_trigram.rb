class EnableTrigram < ActiveRecord::Migration[6.1]
  def change
    enable_extension :pg_trgm

    add_index :goals, :name, opclass: :gin_trgm_ops, using: :gin
  end
end
