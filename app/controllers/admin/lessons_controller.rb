module Admin
  class LessonsController < InertiaController
    include LessonSerializer

    def index
      authorize :admin_lesson, :index?
      lessons = policy_scope(Lesson).includes(:teacher, :student).order(scheduled_at: :desc)

      lessons = lessons.where(teacher_id: params[:teacher_id]) if params[:teacher_id].present?
      lessons = lessons.where(student_id: params[:student_id]) if params[:student_id].present?
      lessons = lessons.where(status: params[:status]) if params[:status].present?

      teachers = User.joins(:roles).where(roles: { name: "teacher" }).map { |u| { id: u.id, name: u.name } }
      students = User.joins(:roles).where(roles: { name: "student" }).map { |u| { id: u.id, name: u.name } }

      render inertia: "admin/Lessons", props: {
        lessons: lessons.map { |l| lesson_json(l) },
        teachers: teachers,
        students: students
      }
    end
  end
end
