require "test_helper"

class LessonPolicyTest < ActiveSupport::TestCase
  setup do
    @ivan = create(:user, :teacher)
    @ana = create(:user, :student)
    @pedro = create(:user, :student)
    @maria = create(:user, :coordinator)
    create(:teacher_profile, user: @ivan)
    @lesson = create(:lesson, teacher: @ivan, student: @ana)
  end

  test "any authenticated user can list lessons" do
    assert LessonPolicy.new(@ana, Lesson).index?
    assert LessonPolicy.new(@ivan, Lesson).index?
  end

  test "teacher can see own lesson" do
    assert LessonPolicy.new(@ivan, @lesson).show?
  end

  test "student can see own lesson" do
    assert LessonPolicy.new(@ana, @lesson).show?
  end

  test "unrelated student cannot see lesson" do
    refute LessonPolicy.new(@pedro, @lesson).show?
  end

  test "coordinator can see any lesson" do
    assert LessonPolicy.new(@maria, @lesson).show?
  end

  test "teacher can create lesson" do
    assert LessonPolicy.new(@ivan, Lesson.new).create?
  end

  test "student cannot create lesson" do
    refute LessonPolicy.new(@ana, Lesson.new).create?
  end

  test "teacher can update own lesson" do
    assert LessonPolicy.new(@ivan, @lesson).update?
  end

  test "student who is part of lesson can update it" do
    assert LessonPolicy.new(@ana, @lesson).update?
  end

  test "unrelated student cannot update lesson" do
    refute LessonPolicy.new(@pedro, @lesson).update?
  end

  test "coordinator can update any lesson" do
    assert LessonPolicy.new(@maria, @lesson).update?
  end

  # === Scope ===

  test "teacher scope returns only taught lessons" do
    scope = LessonPolicy::Scope.new(@ivan, Lesson).resolve
    assert scope.all? { |l| l.teacher_id == @ivan.id }
  end

  test "student scope returns only booked lessons" do
    scope = LessonPolicy::Scope.new(@ana, Lesson).resolve
    assert scope.all? { |l| l.student_id == @ana.id }
  end

  test "coordinator scope returns all lessons" do
    scope = LessonPolicy::Scope.new(@maria, Lesson).resolve
    assert_includes scope, @lesson
  end
end
