require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = create(:user, :student, has_homologation: true, has_education: false)
    @coordinator = create(:user, :coordinator, has_homologation: true, has_education: false)
    @teacher = create(:user, :teacher)
    @admin = create(:user, :super_admin)
  end

  # --- Smart redirect: students ---

  test "student with only homologation is redirected to requests" do
    sign_in @student
    get dashboard_path
    assert_redirected_to homologation_requests_path
  end

  test "student with only education is redirected to lessons" do
    @student.update!(has_homologation: false, has_education: true)
    sign_in @student
    get dashboard_path
    assert_redirected_to lessons_path
  end

  test "student with both cabinets sees dashboard" do
    @student.update!(has_homologation: true, has_education: true)
    sign_in @student
    get dashboard_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  # --- Smart redirect: coordinators ---

  test "coordinator with homologation is redirected to chats" do
    sign_in @coordinator
    get dashboard_path
    assert_redirected_to chats_path
  end

  test "coordinator with only education is redirected to teachers" do
    @coordinator.update!(has_homologation: false, has_education: true)
    sign_in @coordinator
    get dashboard_path
    assert_redirected_to teachers_path
  end

  test "coordinator with both cabinets is redirected to teachers" do
    @coordinator.update!(has_homologation: true, has_education: true)
    sign_in @coordinator
    get dashboard_path
    assert_redirected_to teachers_path
  end

  # --- Smart redirect: teachers & admin ---

  test "teacher is redirected to lessons" do
    sign_in @teacher
    get dashboard_path
    assert_redirected_to lessons_path
  end

  test "super_admin sees dashboard" do
    sign_in @admin
    get dashboard_path
    assert_response :ok
    assert_equal "dashboard/Index", inertia.component
  end

  test "unauthenticated redirects to login" do
    get dashboard_path
    assert_redirected_to new_session_path
  end

  # --- Features flags: cabinet ---

  test "features include hasHomologation true for homologation student" do
    @student.update!(has_homologation: true, has_education: true)
    sign_in @student
    get dashboard_path
    assert_equal true, inertia.props[:features][:hasHomologation]
  end

  test "features include hasEducation true for teacher" do
    sign_in @teacher
    get lessons_path
    assert_equal true, inertia.props[:features][:hasEducation]
    assert_equal false, inertia.props[:features][:hasHomologation]
  end

  test "features include both flags true for super admin" do
    sign_in @admin
    get dashboard_path
    assert_equal true, inertia.props[:features][:hasHomologation]
    assert_equal true, inertia.props[:features][:hasEducation]
  end
end
