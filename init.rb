require_dependency 'already_read'

Rails.application.config.to_prepare do
  Dir[File.dirname(__FILE__) +"/lib/redmine_already_read/*.rb"].each {|file| require file }
  unless Issue.include?(AlreadyRead::IssuePatch)
    Issue.send(:include, AlreadyRead::IssuePatch)
    IssuesController.send(:include, AlreadyRead::IssuesControllerPatch)
    User.send(:include, AlreadyRead::UserPatch)
    IssueQuery.add_available_column(QueryColumn.new(:already_read))
    IssueQuery.add_available_column(QueryColumn.new(:already_read_date))
    IssueQuery.send(:include, AlreadyRead::IssueQueryPatch)
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
  activity_provider :issues, :class_name => 'AlreadyRead', :default => false

end
