module AlreadyReadLib
  module UserPatch
    def self.included(base)
      base.class_eval do
        has_many :already_reads, -> {order('already_reads.created_on')}
        has_many :already_read_issues, :through => :already_reads, :source => :issue
      end
    end
  end
end
