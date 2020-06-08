module RedmineAlreadyRead
  module IssueQueryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods) # obj.method
      class << base
        attr_accessor :next_instance_requires_additional_only_unreads_filter_injection
        IssueQuery.next_instance_requires_additional_only_unreads_filter_injection=false
      end
      base.class_eval do
        # terrible chaining is necessary to stay compatible with RedmineUP plugins
        alias_method :initialize_available_filters_without_already_read, :initialize_available_filters
			  alias_method :initialize_available_filters, :initialize_available_filters_with_already_read
        alias_method :initialize_without_already_read, :initialize
        alias_method :initialize, :initialize_with_already_read
        self.available_columns += [
          QueryColumn.new(:already_read, :sortable => lambda {
            "(select count(*) from already_reads where already_reads.issue_id=#{Issue.table_name}.id and already_reads.user_id=#{User.current.id})"
          }, :default_order => 'desc'),
          QueryColumn.new(:already_read_date, :sortable => lambda {
            "(select already_reads.created_on from already_reads where already_reads.issue_id=#{Issue.table_name}.id and already_reads.user_id=#{User.current.id})"
          }, :default_order => 'desc')
        ]
      end
    end

    module InstanceMethods # obj.method
      def initialize_with_already_read *args
        initialize_without_already_read *args
        if IssueQuery.next_instance_requires_additional_only_unreads_filter_injection
          IssueQuery.next_instance_requires_additional_only_unreads_filter_injection = false
          self.add_filter 'already_read', '<>', ["#{User.current.id}"]
        end
      end

      def initialize_available_filters_with_already_read
        initialize_available_filters_without_already_read
  
        unless available_filters.key?('already_read')
          add_available_filter 'already_read', {:type => :list, :order => 20, :values => @available_filters['author_id'][:values], :name => l(:field_already_read)}
        end
      end
      
      def sql_for_already_read_date_field(field, operator, value)
        sql = "(#{Issue.table_name}.id IN (#{AlreadyRead.select(:issue_id).where('date(created_on) = ?', value).to_sql}))"
        return sql
      end
      def sql_for_already_read_field(field, operator, value)
        if value.include?('me') && value.delete('me')
          if User.current.logged?
            value.push(User.current.id.to_s)
          elsif value.empty?
            value.push("0")
          end
        end
        op = ('=' == operator)? 'IN' : 'NOT IN'
        sql = "#{Issue.table_name}.id #{op} (SELECT #{AlreadyRead.table_name}.issue_id FROM #{AlreadyRead.table_name} WHERE " + sql_for_field(field, '=', value, AlreadyRead.table_name, 'user_id') + ")"
        return sql
      end
    end
  end
end
