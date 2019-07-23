require_dependency 'hook'

Rails.application.config.to_prepare do
  unless Issue.include?(AlreadyReadLib::IssuePatch)
    Issue.send(:include, AlreadyReadLib::IssuePatch)
    IssuesController.send(:include, AlreadyReadLib::IssuesControllerPatch)
    User.send(:include, AlreadyReadLib::UserPatch)
    IssueQuery.add_available_column(QueryColumn.new(:already_read))
    IssueQuery.add_available_column(QueryColumn.new(:already_read_date))
    IssueQuery.send(:include, AlreadyReadLib::IssueQueryPatch)
  end
end

Redmine::Plugin.register :redmine_already_read do
  name 'Redmine Already Read plugin'
  author 'OZAWA Yasuhiro'
  description 'Markup read issues.'
  version '0.0.5'
  url 'https://github.com/egisz/redmine_already_read'
  #author_url 'http://blog.livedoor.jp/ameya86/'

  # Nepadeda, nes neperduoda kazkodel projekto :(
  # Redmine::AccessControl.permission(:view_issues).actions << "issues/bulk_set_read" 
  activity_provider :issues, :class_name => 'AlreadyRead'

end
