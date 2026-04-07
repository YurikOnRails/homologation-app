class ProfilesController < InertiaController
  include UserSerializer
  include TelegramConnectable

  before_action :set_user
  skip_before_action :require_complete_profile

  def edit
    authorize @user, :edit?, policy_class: ProfilePolicy
    render inertia: "profile/Edit", props: { profile: profile_json(@user) }
  end

  def update
    authorize @user, :update?, policy_class: ProfilePolicy
    if @user.update(profile_params)
      redirect_to dashboard_path, notice: t("flash.profile_updated")
    else
      redirect_to edit_profile_path, inertia: { errors: @user.errors }
    end
  end

  private

  def set_user = @user = Current.user

  def telegram_disconnect_redirect_path = edit_profile_path

  def profile_params
    params.permit(:name, :phone, :whatsapp, :birthday, :country, :locale,
                  :is_minor, :guardian_name, :guardian_email, :guardian_phone, :guardian_whatsapp,
                  :notification_email, :notification_telegram)
  end
end
