module Admin
  class DashboardController < InertiaController
    include RequestSerializer

    def index
      authorize :admin_dashboard, :index?

      render inertia: "admin/Dashboard", props: {
        stats: {
          totalRequests: HomologationRequest.count,
          openRequests: HomologationRequest.where.not(status: %w[resolved closed draft]).count,
          awaitingPayment: HomologationRequest.where(status: "awaiting_payment").count,
          resolved: HomologationRequest.where(status: "resolved").count,
          totalUsers: User.kept.count,
          totalTeachers: User.joins(:roles).where(roles: { name: "teacher" }).count
        },
        finance: build_finance,
        requestsByMonth: requests_by_month,
        requestsByStatus: HomologationRequest.group(:status).count,
        recentRequests: HomologationRequest
          .includes(:user)
          .order(created_at: :desc)
          .limit(10)
          .map { |r| request_list_json(r) },
        failedSyncs: HomologationRequest.where.not(amo_crm_sync_error: nil).count
      }
    end

    private

    def build_finance
      paid = HomologationRequest.where.not(payment_amount: [ nil, 0 ])
      paid_count = paid.count
      total_revenue = paid.sum(:payment_amount).to_f

      revenue_by_year = paid
        .group(:year)
        .sum(:payment_amount)
        .transform_values(&:to_f)

      education_revenue, education_count = Lesson.where(status: "completed")
        .joins("INNER JOIN teacher_profiles ON teacher_profiles.user_id = lessons.teacher_id")
        .pick(Arel.sql("COALESCE(SUM(teacher_profiles.hourly_rate * lessons.duration_minutes / 60.0), 0)"), Arel.sql("COUNT(*)"))
      education_revenue = education_revenue.to_f

      {
        homologationRevenue: total_revenue,
        homologationCount: paid_count,
        averageDeal: paid_count > 0 ? (total_revenue / paid_count).round(2) : 0,
        revenueByYear: revenue_by_year,
        educationRevenue: education_revenue,
        educationLessons: education_count,
        totalRevenue: total_revenue + education_revenue
      }
    end

    def requests_by_month
      months = (0..11).map { |i| (Date.current << i).strftime("%Y-%m") }.reverse
      counts = HomologationRequest
        .where(created_at: 12.months.ago..)
        .group("strftime('%Y-%m', created_at)")
        .order("1")
        .count
      months.index_with { |m| counts[m] || 0 }
    end
  end
end
