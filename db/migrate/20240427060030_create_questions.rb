class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :text, null: false
      t.integer :energy, null: false
      t.integer :information, null: false
      t.integer :decision, null: false
      t.integer :response, null: false
      t.integer :stress, null: false

      t.timestamps
    end
    add_index :questions, :text, unique: true
  end
end
