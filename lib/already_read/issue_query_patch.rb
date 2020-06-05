module AlreadyRead
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods) # obj.method

      base.class_eval do
        attr_accessor :next_instance_requires_additional_only_unreads_filter_injection
        IssueQuery.next_instance_requires_additional_only_unreads_filter_injection=false
        
        # horrible chaining is necessary to stay compatible with RedmineUP plugins
        alias_method :initialize_available_filters_without_already_read, :initialize_available_filters
        alias_method :initialize_available_filters, :initialize_available_filters_with_already_read
      end
    end

    module InstanceMethods # obj.method
      def initialize *args
        super *args
        if IssueQuery.next_instance_requires_additional_only_unreads_filter_injection
          IssueQuery.next_instance_requires_additional_only_unreads_filter_injection = false
          self.add_filter 'already_read', '<>', ["#{User.current.id}"]
        end
        # self
      end
    
      def initialize_available_filters_with_already_read
        initialize_available_filters_without_already_read

        unless available_filters.key?('already_read')
          add_available_filter 'already_read', {:type => :list, :order => 20, :values => @available_filters['author_id'][:values], :name => l(:field_already_read)}
        end
      end
      

      def sql_for_already_read_field(field, operator, value)
        db_table = AlreadyRead.table_name
        # <<自分>>を変換
        if value.include?('me') && value.delete('me')
          if User.current.logged?
            value.push(User.current.id.to_s)
          elsif value.empty?
            value.push("0")
          end
        end
        op = ('=' == operator)? 'IN' : 'NOT IN'

        sql = "#{Issue.table_name}.id #{op} (SELECT #{db_table}.issue_id FROM #{db_table} WHERE " + sql_for_field(field, '=', value, db_table, 'user_id') + ")"

        return sql
      end

      def sql_for_already_read_date_field(field, operator, value)
        sql = "(#{Issue.table_name}.id IN (#{AlreadyRead.select(:issue_id).where('date(created_on) = ?', value).to_sql}))"
        return sql
      end
    end
  end
end
