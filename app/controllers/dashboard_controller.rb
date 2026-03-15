class DashboardController < InertiaController
  def index
    skip_authorization
    render inertia: "dashboard/Index", props: {}
  end
end
