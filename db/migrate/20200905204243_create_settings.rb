class CreateSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :settings do |t|
      t.references :owner, polymorphic: true, null: false
      t.references :parent, polymorphic: true, null: false
      t.string :key
      t.string :value
      t.string :cls

      t.timestamps
    end
  end
end
