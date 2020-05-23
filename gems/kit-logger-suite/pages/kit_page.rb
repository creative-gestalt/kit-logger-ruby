module SingleCarePages
  class Kit_Page < SCPage

    text 'group_number', id('txtGroupNumber')
    text 'member_number', id('txtMemberNumber')
    button 'drop_off', id('btnDropOffKit')
    button 'log_kit', id('btnLogDropOffKit')
    button 'close', css("button[class='close']")
    element 'modal_shadow', css('div#dropOffKit')

    def drop_off_kits
      wait_until { drop_off_element.visible? }
      wait_until { !modal_shadow_element.visible? }
      drop_off
    end

    def set_group(group)
      wait_until { group_number_element.visible? }
      sleep 0.3
      self.group_number = group
    end

    def set_member(member)
      wait_until { member_number_element.visible? }
      self.member_number = member
    end

    def close_tab
      @driver.window.close
      @driver.window.use_window 0
    end

  end
end
