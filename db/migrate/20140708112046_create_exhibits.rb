class CreateExhibits < ActiveRecord::Migration
  def change
    create_table :exhibits do |t|
      t.string :subtype, index: true
      t.string :name
      t.string :author
      t.string :year
      t.string :materials
      t.string :size
      t.string :owner
      t.string :image
      t.integer :image_width
      t.integer :image_height

      t.timestamps
    end
  end
end
