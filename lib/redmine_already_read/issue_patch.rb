module RedmineAlreadyRead
  module IssuePatch
    def self.included(base) # :nodoc:
      base.send(:prepend, InstanceMethods) # obj.method

      base.class_eval do
        has_many :already_reads, :class_name => 'AlreadyRead'
        has_many :already_read_users, :through => :already_reads, :source => :user
        after_update :reset_already_read
      end
    end

    module InstanceMethods # obj.method
      # チケットのclassに既読／未読も追加する
      def css_classes(user=User.current)
        s = super(user)
        s << ((self.already_read?)? ' read' : ' unread')
        s << ((self.new_unread?)? ' new' : '')
        return s
      end

      # 状態を文字で返す
      def already_read(user = User.current)
        return (already_read?(user))? l(:label_already_read_read) : l(:label_already_read_unread)
      end

      # 既読ならtrueを返す
      def already_read?(user = User.current)
       return !user.anonymous? && user.already_read_issue_ids.include?(self.id)
      end

        # 既読ならtrueを返す
      def new_unread?(user = User.current)
       return !already_read? && !closed? && created_on > Date.today - 7
      end

      # チケットを読んだ日
      def already_read_date(user = User.current)
        read = already_reads.detect{|r| r.user_id == user.id}
        return (read)? read.created_on : nil
      end

      private
      # 既読フラグはチケットを更新したらリセットする
      def reset_already_read
        AlreadyRead.where(:issue_id => self.id).destroy_all
      end
    end
  end
end
