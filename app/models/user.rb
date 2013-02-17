require 'hashie'

class User < ActiveRecord::Base

  devise :database_authenticatable, :omniauthable

  attr_accessible :entity, :app_id, :app_mac, :profile, :mac_key_id, :mac_key, :mac_algorithm, :profile_info_types, :post_types

  has_many :samples

  # plugin :serialization
  # serialize_attributes :pg_array, :profile_info_types, :post_types
  # serialize_attributes :json, :app_mac, :profile

  def self.find_or_create_from_auth_hash(auth_hash)
    user = User.where(:entity => auth_hash.uid).first

    app = auth_hash.extra.raw_info.app
    app_auth = auth_hash.extra.raw_info.app_authorization
    credentials = auth_hash.extra.credentials

    attributes = {
      :entity => auth_hash.uid,
      :app_id => app.id,
      :app_mac => {
        'mac_key_id' => app.mac_key_id,
        'mac_key' => app.mac_key,
        'mac_algorithm' => app.mac_algorithm
      }.to_json,
      :profile => auth_hash.extra.raw_info.profile.to_json,
      :mac_key_id => app_auth.access_token,
      :mac_key => app_auth.mac_key,
      :mac_algorithm => app_auth.mac_algorithm,
      :profile_info_types => app_auth.profile_info_types,
      :post_types => app_auth.post_types
    }

    if user
      puts "UPDATING", attributes.to_json
      user.update_attributes(attributes)
      user
    else
      puts "CREATING"
      create(attributes)
    end
  end

  def self.app_created_for_entity(app, entity)
    return unless user = User.where(:entity => entity).first
    user.destroy
  end

  def self.get_app_from_entity(entity)
    return unless user = User.where(:entity => entity).first
    user.app_mac = JSON.parse(user.app_mac)
    Hashie::Mash.new(
      :id => user.app_id,
      :mac_key_id => user.app_mac['mac_key_id'],
      :mac_key => user.app_mac['mac_key'],
      :mac_algorithm => user.app_mac['mac_algorithm']
    )
  end

  def primary_server
    (core_profile['servers'] || []).first
  end

  def auth_details
    {
      :mac_key_id => mac_key_id,
      :mac_key => mac_key,
      :mac_algorithm => mac_algorithm
    }
  end

  def basic_profile
    (JSON.parse(profile) || {})['https://tent.io/types/info/basic/v0.1.0'] || {}
  end

  def core_profile
    (JSON.parse(profile) || {})['https://tent.io/types/info/core/v0.1.0'] || {}
  end

  def encrypted_password
    # dummy to fake out :database_authenticatable.
    # when I remove :database_authenticatable, some necessary routes (/users/sign_out) aren't generated.
  end

  def is_admin?
    self.is_admin == 1
  end

  def first_name
    self.name.split(' ').first if self.name
  end

  def name 
    self.basic_profile['name']
  end
end