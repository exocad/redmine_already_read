module AlreadyRead
  module IssuesControllerPatch
    def self.included(base)
      base.send :include, InstanceMethods

      base.class_eval do
        # overrides main :'(
        before_filter :authorize, :except => [:index, :new, :create, :bulk_set_read] 
        after_filter :issue_read, :only => :show
        after_filter :set_read, :only => :bulk_update
      end
    end

    module InstanceMethods

      def set_read
        issues = Issue.where(:id => params["ids"]);
        User.current.already_read_issues << issues.reject{|issue| issue.already_read?}
      end

      def bulk_set_read
        issues = Issue.where(:id => params["ids"]);
        if params[:set_unread]
			AlreadyRead.where(:issue_id => params[:ids], :user_id => User.current.id).destroy_all
        else
          User.current.already_read_issues << issues.reject{|issue| issue.already_read?}
		end
		# redirect only if this route has been directly accessed
		redirect_back_or_default({:controller => 'issues', :action => 'index', :project_id => @project}) if request.path == '/issues/bulk_set_read'
      end

      private
      # 既読フラグを付ける
      def issue_read
        if User.current.logged? && @issue && !@issue.already_read?
          User.current.already_read_issues << @issue
        end
      end
    end
  end
end