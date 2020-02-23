class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :type
      t.string :firstName
      t.string :lastName
      t.string :userName
      t.string :box
      t.string :email
      t.string :address
      t.string :phone
      t.string :imgPath
      t.string :homeAddress

      t.timestamps
    end
  end
end
