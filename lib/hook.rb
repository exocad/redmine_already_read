module AlreadyReadLib
  class HookListener < Redmine::Hook::ViewListener
    render_on :view_issues_context_menu_end, :partial => 'already_read/update_context'
    render_on :view_issues_index_bottom, :partial => 'already_read/view_issues_index_bottom'
    def view_layouts_base_html_head(context = {})
        stylesheet_link_tag 'already_read.css', :plugin => 'redmine_already_read'
    end
  end
end
