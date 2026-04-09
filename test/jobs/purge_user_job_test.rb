require "test_helper"

class PurgeUserJobTest < ActiveJob::TestCase
  setup do
    @user = create(:user, :student)
  end

  test "performs purge when purge_scheduled_at is set" do
    @user.update!(purge_scheduled_at: Time.current)
    user_id = @user.id
    PurgeUserJob.perform_now(user_id)
    assert_nil User.find_by(id: user_id)
  end

  test "skips purge when user is not found" do
    assert_nothing_raised { PurgeUserJob.perform_now(999_999) }
  end

  test "skips purge when purge_scheduled_at is nil (cancelled)" do
    user_id = @user.id
    PurgeUserJob.perform_now(user_id)
    assert User.exists?(user_id)
  end
end
