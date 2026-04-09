module Admin
  class UsersController < InertiaController
    before_action :set_user, only: [ :edit, :update, :destroy, :assign_role, :remove_role, :gdpr_delete, :schedule_purge, :cancel_purge ]

    def index
      authorize User
      render inertia: "admin/Users", props: {
        users: users_list
      }
    end

    def new
      authorize User
      render inertia: "admin/Users", props: {
        users: users_list,
        newUser: true
      }
    end

    def create
      authorize User
      @user = User.new({ has_homologation: true }.merge(user_params))
      if @user.save
        redirect_to admin_users_path, notice: t("flash.user_created")
      else
        redirect_to admin_users_path, inertia: { errors: @user.errors }
      end
    end

    def edit
      authorize @user
      render inertia: "admin/Users", props: {
        users: users_list,
        editUser: admin_user_json(@user)
      }
    end

    def update
      authorize @user
      if @user.update(user_params)
        redirect_to admin_users_path, notice: t("flash.user_updated")
      else
        redirect_to admin_users_path, inertia: { errors: @user.errors.to_hash(true) }
      end
    end

    def destroy
      authorize @user
      @user.discard
      redirect_to admin_users_path, notice: t("flash.user_deactivated")
    end

    def gdpr_delete
      authorize @user, :destroy?
      unless @user.deletion_requested_at.present?
        return redirect_to admin_users_path, alert: t("flash.gdpr_delete_not_requested")
      end
      @user.gdpr_anonymize!
      redirect_to admin_users_path, notice: t("flash.user_gdpr_deleted")
    end

    def schedule_purge
      authorize @user, :destroy?
      @user.schedule_purge!
      redirect_to admin_users_path, notice: t("flash.user_purge_scheduled")
    end

    def cancel_purge
      authorize @user, :destroy?
      @user.cancel_purge!
      redirect_to admin_users_path, notice: t("flash.user_purge_cancelled")
    end

    def assign_role
      authorize @user, :update?
      role = Role.find_by!(name: params[:role_name])
      @user.roles << role unless @user.roles.include?(role)
      redirect_to admin_users_path, notice: t("flash.role_assigned")
    end

    def remove_role
      authorize @user, :update?
      role = Role.find_by!(name: params[:role_name])
      @user.roles.delete(role)
      redirect_to admin_users_path, notice: t("flash.role_removed")
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def users_list
      users = policy_scope(User).includes(:roles, :homologation_requests).order(created_at: :desc)
      all_req_ids = users.flat_map { |u| u.homologation_requests.map(&:id) }
      file_counts = all_req_ids.any? ?
        ActiveStorage::Attachment
          .where(record_type: "HomologationRequest", record_id: all_req_ids)
          .group(:record_id).count
        : {}
      users.map { |u| admin_user_json(u, file_counts) }
    end

    def user_params
      params.require(:user).permit(:name, :email_address, :password, :locale, :has_homologation, :has_education)
    end

    def admin_user_json(u, file_counts = {})
      req_ids = u.homologation_requests.map(&:id)
      file_count = req_ids.sum { |rid| file_counts[rid] || 0 }
      purgeable = u.homologation_requests.all? { |r| User::PURGEABLE_STATUSES.include?(r.status) }
      { id: u.id, name: u.name, email: u.email_address,
        roles: u.roles.map(&:name), locale: u.locale,
        avatarUrl: u.avatar_url, createdAt: u.created_at.iso8601,
        discarded: u.discarded?,
        deletionRequestedAt: u.deletion_requested_at&.iso8601,
        hasHomologation: u.has_homologation?,
        hasEducation: u.has_education?,
        purgeScheduledAt: u.purge_scheduled_at&.iso8601,
        purgeable: purgeable,
        purgeStats: { requests: req_ids.size, files: file_count } }
    end
  end
end
