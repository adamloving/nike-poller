Rails.application.config.middleware.use OmniAuth::Builder do
  name = 'Nike poller'
  name += ' ' + Rails.env unless Rails.env == 'production'

  provider :tent,
    :get_app => lambda { |entity| User.get_app_from_entity(entity) },
    :on_app_created => lambda { |app, entity| User.app_created_for_entity(app, entity) },
    :app => {
      :name => name,
      :icon => '',
      :url => ENV['ROOT_URL'],
      :description => 'Downloads Nike+ data',
      :scopes => {
        "read_posts" => "See status posts",
        "write_posts" => "Create status posts",
        "read_profile" => "Show your basic profile",
        "write_profile" => "Save app specific data",
        "read_followings" => "See who you are following",
        "write_followings" => "Follow new entities",
        "read_followers" => "See who is following you",
        "write_followers" => "Block followers from receiving notifications",
        "read_groups" => "Add group to post permissions",
        "write_groups" => "Add new group to post permissions",
        "read_permissions" => "Display who can see a post"
      }
    },
    :post_types => %w(https://tent.io/types/post/status/v0.1.0),
    :profile_info_types => %w(https://tent.io/types/info/tent-status/v0.1.0)
end