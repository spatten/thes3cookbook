class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.string :name, :default => ""
      t.boolean :is_on_s3, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
