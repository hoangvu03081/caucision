# frozen_string_literal: true

class EnablePkce < ActiveRecord::Migration[7.0]
  def change
    add_column :oauth_access_grants, :code_challenge, :text, null: true
    add_column :oauth_access_grants, :code_challenge_method, :text, null: true
  end
end
