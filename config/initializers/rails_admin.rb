RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.authorize_with do
    authenticate_or_request_with_http_basic('Site Message') do |username, password|
      username == ENV['admin_user'] && password == ENV['admin_pass']
    end
  end

  config.model 'User' do
    navigation_label 'Masterdata'
    weight -9
    list do
      exclude_fields :password_digest, :auth_token
    end
    export do
      exclude_fields :password_digest, :auth_token
    end
    edit do
      exclude_fields :password_digest, :auth_token
    end
    show do
      exclude_fields :password_digest, :auth_token
    end
  end
  config.model 'Device' do
    navigation_label 'Masterdata'
    weight -7
    list do
      exclude_fields :push_token
    end
    export do
      exclude_fields :push_token
    end
    edit do
      exclude_fields :push_token
    end
    show do
      exclude_fields :push_token
    end
  end
  config.model 'Friendship' do
    navigation_label 'Masterdata'
    weight -5
  end
  config.model 'Friendrequest' do
    navigation_label 'Masterdata'
    weight -4
  end

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    #new
    export
    show
    #edit
    #delete
    #bulk_delete
    #history_index
    #show
    #edit
    #history_show
    #show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
