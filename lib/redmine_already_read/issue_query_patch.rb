module RedmineAlreadyRead
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods) # obj.method
    end

    module InstanceMethods # obj.method
      def sql_for_already_read_date_field(field, operator, value)
        sql = "(#{Issue.table_name}.id IN (#{AlreadyRead.select(:issue_id).where('date(created_on) = ?', value).to_sql}))"
        return sql
      end
    end
  end
end
