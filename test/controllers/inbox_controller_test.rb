require "test_helper"

class InboxControllerTest < ActionDispatch::IntegrationTest
  test "coordinator can access inbox" do
    sign_in users(:coordinator_maria)
    get inbox_index_path
    assert_response :ok
    assert_equal "inbox/Index", inertia.component
  end

  test "super_admin can access inbox" do
    sign_in users(:super_admin_boss)
    get inbox_index_path
    assert_response :ok
    assert_equal "inbox/Index", inertia.component
  end

  test "student cannot access inbox" do
    sign_in users(:student_ana)
    get inbox_index_path
    assert_response :forbidden
  end

  test "teacher cannot access inbox" do
    sign_in users(:teacher_ivan)
    get inbox_index_path
    assert_response :forbidden
  end

  test "coordinator can view conversation in inbox" do
    sign_in users(:coordinator_maria)
    get inbox_path(conversations(:ana_equivalencia_conversation))
    assert_response :ok
    assert_equal "inbox/Index", inertia.component
  end

  test "inbox index includes conversations list" do
    sign_in users(:coordinator_maria)
    get inbox_index_path
    assert_response :ok
    props = inertia.props
    assert props[:conversations].is_a?(Array)
  end
end
