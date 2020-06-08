module RedmineAlreadyRead
  module MyHelperPatch
    def self.included(base) # :nodoc:
      base.send(:prepend, InstanceMethods) # obj.method
    end
  	
    module InstanceMethods # obj.method

  		def render_blocks(blocks, user, options={})
  			s = super(blocks, user, options)
  			if @requires_watchers_only_filter_rendering && !@is_watchers_only_filter_rendered
  				script = render :partial => 'already_read/my_page.js'
  				s = script.html_safe + s;
  				@is_watchers_only_filter_rendered = true
  			end
  			s
  		end
  		
  		def render_block(block, user)
  			@requires_watchers_only_filter_rendering = true;
  			unread_only = user.pref.my_page_settings(block)[:unread_only]  == '1'
  			if unread_only
  				IssueQuery.next_instance_requires_additional_only_unreads_filter_injection = true
  			end 
  			ret = super(block, user)
  			ret = ret.insert(ret.rindex('</'), ('<script> __inject_only_watchers_setting("'+block+'", '+(unread_only ? 'true' : 'false')+'); </script>').html_safe)
  			ret
  		end
  	end
  end
end