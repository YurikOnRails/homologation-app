require "test_helper"

class EncryptionTest < ActiveSupport::TestCase
  # PII fields must be encrypted at rest (GDPR, Spain LOPD)

  test "user phone is encrypted in database" do
    user = users(:student_ana)
    user.update!(phone: "+34611222333")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT phone FROM users WHERE id = #{user.id}"
    )
    refute_equal "+34611222333", raw, "phone should be encrypted at rest"
    assert_equal "+34611222333", user.reload.phone
  end

  test "user whatsapp is encrypted in database" do
    user = users(:student_ana)
    user.update!(whatsapp: "+34699888777")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT whatsapp FROM users WHERE id = #{user.id}"
    )
    refute_equal "+34699888777", raw, "whatsapp should be encrypted at rest"
    assert_equal "+34699888777", user.reload.whatsapp
  end

  test "guardian phone and whatsapp are encrypted" do
    user = users(:student_ana)
    user.update!(is_minor: true, guardian_phone: "+34699000111", guardian_whatsapp: "+34699000222")

    raw_phone = ActiveRecord::Base.connection.select_value(
      "SELECT guardian_phone FROM users WHERE id = #{user.id}"
    )
    raw_wa = ActiveRecord::Base.connection.select_value(
      "SELECT guardian_whatsapp FROM users WHERE id = #{user.id}"
    )
    refute_equal "+34699000111", raw_phone
    refute_equal "+34699000222", raw_wa
    assert_equal "+34699000111", user.reload.guardian_phone
    assert_equal "+34699000222", user.reload.guardian_whatsapp
  end

  test "homologation request identity_card is encrypted" do
    request = homologation_requests(:ana_equivalencia)
    request.update!(identity_card: "X1234567Z")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT identity_card FROM homologation_requests WHERE id = #{request.id}"
    )
    refute_equal "X1234567Z", raw, "identity_card should be encrypted at rest"
    assert_equal "X1234567Z", request.reload.identity_card
  end

  test "homologation request passport is encrypted" do
    request = homologation_requests(:ana_equivalencia)
    request.update!(passport: "AB123456")

    raw = ActiveRecord::Base.connection.select_value(
      "SELECT passport FROM homologation_requests WHERE id = #{request.id}"
    )
    refute_equal "AB123456", raw
    assert_equal "AB123456", request.reload.passport
  end
end
