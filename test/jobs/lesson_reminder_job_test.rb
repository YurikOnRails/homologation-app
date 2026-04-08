require "test_helper"

class LessonReminderJobTest < ActiveJob::TestCase
  setup do
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @coordinator = create(:user, :coordinator)
    create(:teacher_profile, user: @teacher)
    create(:teacher_student, teacher: @teacher, student: @student, assigned_by: @coordinator.id)
    @lesson = create(:lesson, teacher: @teacher, student: @student)
  end

  test "sends reminder for lessons starting in ~1 hour" do
    freeze_time do
      @lesson.update!(scheduled_at: 60.minutes.from_now, status: "scheduled")

      assert_difference "Notification.count", 2 do  # teacher + student
        perform_enqueued_jobs { LessonReminderJob.perform_now }
      end
    end
  end

  test "does not send reminder for cancelled lessons" do
    freeze_time do
      @lesson.update!(scheduled_at: 60.minutes.from_now, status: "cancelled")

      assert_no_difference "Notification.count" do
        LessonReminderJob.perform_now
      end
    end
  end

  test "does not send reminder for lessons outside the 1-hour window" do
    freeze_time do
      @lesson.update!(scheduled_at: 3.hours.from_now, status: "scheduled")

      assert_no_difference "Notification.count" do
        LessonReminderJob.perform_now
      end
    end
  end
end
