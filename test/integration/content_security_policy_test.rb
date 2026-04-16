require "test_helper"

class ContentSecurityPolicyTest < ActionDispatch::IntegrationTest
  test "public pages send a content security policy header" do
    get root_path

    assert_response :success

    csp = response.headers["Content-Security-Policy"]
    assert_predicate csp, :present?
    assert_includes csp, "object-src 'none'"
    assert_includes csp, "base-uri 'self'"
    assert_includes csp, "form-action 'self'"
  end

  test "admin page builder csp allows unlayer editor resources" do
    sign_in users(:two)

    get new_admin_page_path

    assert_response :success

    csp = response.headers["Content-Security-Policy"]
    assert_predicate csp, :present?
    assert_includes csp, "editor.unlayer.com"
    assert_includes csp, "frame-src"
    assert_includes csp, "connect-src"
  end
end