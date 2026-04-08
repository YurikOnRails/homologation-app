require "test_helper"

class EncryptionTest < ActiveSupport::TestCase
  # PII fields must be encrypted at rest (GDPR, Spain LOPD)

  setup do
    @student = create(:user, :student)
    @request = create(:homologation_request, :submitted, user: @student)
  end

  test "user phone is encrypted in database" do
    @student.update!(phone: "+34611222333")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT phone FROM users WHERE id = #{@student.id}"
    )
    refute_equal "+34611222333", raw, "phone should be encrypted at rest"
    assert_equal "+34611222333", @student.reload.phone
  end

  test "user whatsapp is encrypted in database" do
    @student.update!(whatsapp: "+34699888777")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT whatsapp FROM users WHERE id = #{@student.id}"
    )
    refute_equal "+34699888777", raw, "whatsapp should be encrypted at rest"
    assert_equal "+34699888777", @student.reload.whatsapp
  end

  test "guardian phone and whatsapp are encrypted" do
    @student.update!(is_minor: true, guardian_name: "Test Guardian", guardian_phone: "+34699000111", guardian_whatsapp: "+34699000222")

    raw_phone = ActiveRecord::Base.connection.select_value(
      "SELECT guardian_phone FROM users WHERE id = #{@student.id}"
    )
    raw_wa = ActiveRecord::Base.connection.select_value(
      "SELECT guardian_whatsapp FROM users WHERE id = #{@student.id}"
    )
    refute_equal "+34699000111", raw_phone
    refute_equal "+34699000222", raw_wa
    assert_equal "+34699000111", @student.reload.guardian_phone
    assert_equal "+34699000222", @student.reload.guardian_whatsapp
  end

  test "homologation request identity_card is encrypted" do
    @request.update!(identity_card: "X1234567Z")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT identity_card FROM homologation_requests WHERE id = #{@request.id}"
    )
    refute_equal "X1234567Z", raw, "identity_card should be encrypted at rest"
    assert_equal "X1234567Z", @request.reload.identity_card
  end

  test "homologation request passport is encrypted" do
    @request.update!(passport: "AB123456")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT passport FROM homologation_requests WHERE id = #{@request.id}"
    )
    refute_equal "AB123456", raw
    assert_equal "AB123456", @request.reload.passport
  end
end
