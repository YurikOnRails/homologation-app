require "test_helper"

class LessonTest < ActiveSupport::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @teacher_profile = create(:teacher_profile, user: @teacher, permanent_meeting_link: "https://zoom.us/j/123456")
    @assignment = create(:teacher_student, teacher: @teacher, student: @student)
    @lesson = create(:lesson, teacher: @teacher, student: @student)
  end

  test "effective_meeting_link returns lesson link if present" do
    @lesson.meeting_link = "https://custom.link/123"
    assert_equal "https://custom.link/123", @lesson.effective_meeting_link
  end

  test "effective_meeting_link falls back to teacher permanent link" do
    @lesson.meeting_link = nil
    assert_equal "https://zoom.us/j/123456", @lesson.effective_meeting_link
  end

  test "meeting_link_ready? returns true when link available" do
    assert @lesson.meeting_link_ready?
  end

  test "meeting_link_ready? returns false when no link" do
    @lesson.meeting_link = nil
    @lesson.teacher.teacher_profile.update!(permanent_meeting_link: nil)
    refute @lesson.meeting_link_ready?
  end

  test "validates status inclusion" do
    @lesson.status = "invalid_status"
    refute @lesson.valid?
    assert @lesson.errors[:status].any?
  end

  test "validates scheduled_at presence" do
    lesson = Lesson.new(teacher: @teacher, student: @student, duration_minutes: 60)
    refute lesson.valid?
    assert lesson.errors[:scheduled_at].any?
  end
end
