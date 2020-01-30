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
  url 'https://github.com/exocad/redmine_already_read'
end