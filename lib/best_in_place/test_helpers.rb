module BestInPlace
  module TestHelpers
    include ActionView::Helpers::JavaScriptHelper

    def bip_area(model, attr, new_value)
      id = BestInPlace::Utils.build_best_in_place_id model, attr
      find("##{id}").trigger('click')
      execute_script <<-JS
        $("##{id} form textarea").val('#{escape_javascript new_value.to_s}');
        $("##{id} form textarea").blur();
      JS
      wait_for_ajax
    end

    def bip_text(model, attr, new_value)
      id = BestInPlace::Utils.build_best_in_place_id model, attr
      find("##{id}").click
      execute_script <<-JS
        $("##{id} input[name='#{attr}']").val('#{escape_javascript new_value.to_s}');
        $("##{id} form").submit();
      JS
      wait_for_ajax
    end

    def bip_bool(model, attr)
      id = BestInPlace::Utils.build_best_in_place_id model, attr
      find("##{id}").trigger('click')
      wait_for_ajax
    end

    def bip_select(model, attr, name)
      id = BestInPlace::Utils.build_best_in_place_id model, attr
      find("##{id}").trigger('click')
      find("##{id}").select(name)
      wait_for_ajax
    end

    def wait_for_ajax
      return unless respond_to?(:evaluate_script)
      wait_until { finished_all_ajax_requests? }
    end

    def finished_all_ajax_requests?
      evaluate_script('!window.jQuery') || evaluate_script('jQuery.active').zero?
    end

    def wait_until(max_execution_time_in_seconds = Capybara.default_max_wait_time)
      Timeout.timeout(max_execution_time_in_seconds) do
        loop do
          if yield
            return true
          else
            sleep(0.2)
            next
          end
        end
      end
    end

  end
end
