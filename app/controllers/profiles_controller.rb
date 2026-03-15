class ProfilesController < InertiaController
  before_action :set_user
  skip_before_action :require_complete_profile

  def edit
    authorize @user, :edit?, policy_class: ProfilePolicy
    render inertia: "profile/Edit", props: { profile: profile_json(@user) }
  end

  def update
    authorize @user, :update?, policy_class: ProfilePolicy
    if @user.update(profile_params)
      redirect_to root_path, notice: t("flash.profile_updated")
    else
      redirect_to edit_profile_path, inertia: { errors: @user.errors }
    end
  end

  private

  def set_user = @user = Current.user

  def profile_params
    params.permit(:name, :phone, :whatsapp, :birthday, :country, :locale,
                  :is_minor, :guardian_name, :guardian_email, :guardian_phone, :guardian_whatsapp)
  end

  def profile_json(u)
    { id: u.id, name: u.name, email: u.email_address, phone: u.phone, whatsapp: u.whatsapp,
      birthday: u.birthday&.iso8601, country: u.country, locale: u.locale,
      isMinor: u.is_minor, guardianName: u.guardian_name, guardianEmail: u.guardian_email,
      guardianPhone: u.guardian_phone, guardianWhatsapp: u.guardian_whatsapp,
      profileComplete: u.profile_complete? }
  end
end
