require "test_helper"

class AdminFormsTest < ActionDispatch::IntegrationTest
  test "admin can browse forms and export csv" do
    sign_in users(:two)

    get admin_forms_path

    assert_response :success
    assert_match "Forms", response.body
    assert_match "Contact Request", response.body

    get admin_form_submissions_path(forms(:free_contact))
    assert_response :success
    assert_match "ada@example.com", response.body

    get admin_form_submission_path(forms(:free_contact), form_submissions(:free_submission))
    assert_response :success
    assert_match "Ada Lovelace", response.body

    get export_admin_form_submissions_path(forms(:free_contact), format: :csv)
    assert_response :success
    assert_includes response.media_type, "text/csv"
    assert_includes response.body, "full_name"
    assert_includes response.body, "Ada Lovelace"
  end

  test "non admin cannot access forms dashboard" do
    sign_in users(:one)

    get admin_forms_path

    assert_redirected_to root_path
  end
end