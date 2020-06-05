require_dependency 'redmine_already_read'

Rails.application.config.to_prepare do
  Dir[File.dirname(__FILE__) +"/lib/redmine_already_read/*.rb"].each {|file| require file }
  unless Issue.include?(RedmineAlreadyRead::IssuePatch)
    Issue.send(:include, RedmineAlreadyRead::IssuePatch)
    IssuesController.send(:include, RedmineAlreadyRead::IssuesControllerPatch)
    User.send(:include, RedmineAlreadyRead::UserPatch)
    IssueQuery.add_available_column(QueryColumn.new(:already_read))
    IssueQuery.add_available_column(QueryColumn.new(:already_read_date))
    IssueQuery.send(:include, RedmineAlreadyRead::IssueQueryPatch)
  end
end

Redmine::Plugin.register :redmine_already_read do
  name 'Redmine Already Read plugin'
  author 'OZAWA Yasuhiro'
  description 'Markup read issues.'
  version '0.0.5'
  url 'https://github.com/exocad/redmine_already_read'

  # Nepadeda, nes neperduoda kazkodel projekto :(
  # Redmine::AccessControl.permission(:view_issues).actions << "issues/bulk_set_read" 
  activity_provider :issues, :class_name => 'AlreadyRead', :default => false

end
