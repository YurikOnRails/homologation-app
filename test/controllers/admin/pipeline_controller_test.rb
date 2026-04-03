require "test_helper"

class Admin::PipelineControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = create(:user, :super_admin)
    @coordinator = create(:user, :coordinator)
    @teacher = create(:user, :teacher)
    @student = create(:user, :student)
    @request_record = create(:homologation_request, :submitted, user: @student)
    @request_record.update_columns(
      status: "payment_confirmed",
      payment_confirmed_at: Time.current,
      payment_amount: 500.00,
      pipeline_stage: "pago_recibido",
      document_checklist: HomologationRequest::DEFAULT_DOCUMENT_CHECKLIST,
      year: 2026
    )
  end

  # === Authorization ===

  test "student cannot access pipeline index" do
    sign_in @student
    get admin_pipeline_path
    assert_response :forbidden
  end

  test "coordinator cannot access pipeline index" do
    sign_in @coordinator
    get admin_pipeline_path
    assert_response :forbidden
  end

  test "teacher cannot access pipeline index" do
    sign_in @teacher
    get admin_pipeline_path
    assert_response :forbidden
  end

  test "super_admin can access pipeline index" do
    sign_in @admin
    get admin_pipeline_path
    assert_response :ok
    assert_equal "admin/Pipeline", inertia.component
  end

  # === Index props ===

  test "index returns stages grouped by pipeline_stage" do
    sign_in @admin
    get admin_pipeline_path
    props = inertia.props
    assert props[:stages].is_a?(Hash)
    assert_includes props[:stages].keys, "pago_recibido"
    assert_includes props[:stages].keys, "completado"
  end

  test "index returns stats" do
    sign_in @admin
    get admin_pipeline_path
    stats = inertia.props[:stats]
    assert stats.key?(:active)
    assert stats.key?(:revenue)
    assert stats.key?(:byYear)
    assert stats.key?(:noPago)
    assert stats.key?(:cotejo)
  end

  test "index returns filters" do
    sign_in @admin
    get admin_pipeline_path, params: { year: 2026, q: @student.name.split.first }
    filters = inertia.props[:filters]
    assert_equal "2026", filters[:year]
    assert_equal @student.name.split.first, filters[:q]
  end

  test "index filters by year" do
    sign_in @admin
    get admin_pipeline_path, params: { year: 2026 }
    assert_response :ok
    stages = inertia.props[:stages]
    cards = stages.values.flatten
    assert cards.all? { |c| c[:year] == 2026 }
  end

  # === Advance ===

  test "student cannot advance pipeline" do
    sign_in @student
    patch admin_pipeline_advance_path(@request_record)
    assert_response :forbidden
  end

  test "super_admin can advance pipeline stage" do
    sign_in @admin
    patch admin_pipeline_advance_path(@request_record)
    assert_redirected_to admin_pipeline_path
    assert_equal "documentos", @request_record.reload.pipeline_stage
  end

  test "advance from completado returns error flash" do
    sign_in @admin
    @request_record.update_columns(pipeline_stage: "completado")
    patch admin_pipeline_advance_path(@request_record)
    assert_redirected_to admin_pipeline_path
    assert flash[:alert].present?
  end

  # === Retreat ===

  test "student cannot retreat pipeline" do
    sign_in @student
    patch admin_pipeline_retreat_path(@request_record)
    assert_response :forbidden
  end

  test "super_admin can retreat pipeline stage" do
    sign_in @admin
    @request_record.update_columns(pipeline_stage: "documentos")
    patch admin_pipeline_retreat_path(@request_record)
    assert_redirected_to admin_pipeline_path
    assert_equal "pago_recibido", @request_record.reload.pipeline_stage
  end

  test "retreat from pago_recibido returns error flash" do
    sign_in @admin
    patch admin_pipeline_retreat_path(@request_record)
    assert_redirected_to admin_pipeline_path
    assert flash[:alert].present?
  end

  # === Update ===

  test "student cannot update pipeline fields" do
    sign_in @student
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { pipeline_notes: "test" }
    }
    assert_response :forbidden
  end

  test "super_admin can update pipeline_notes" do
    sign_in @admin
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { pipeline_notes: "Important note" }
    }
    assert_redirected_to admin_pipeline_path
    assert_equal "Important note", @request_record.reload.pipeline_notes
  end

  test "super_admin can update document_checklist" do
    sign_in @admin
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { document_checklist: { sol: "true", vol: "true", tas: "false" } }
    }
    assert_redirected_to admin_pipeline_path
    checklist = @request_record.reload.document_checklist
    assert_equal true, checklist["sol"]
    assert_equal true, checklist["vol"]
    assert_equal false, checklist["tas"]
  end

  test "super_admin can update year" do
    sign_in @admin
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { year: 2025 }
    }
    assert_redirected_to admin_pipeline_path
    assert_equal 2025, @request_record.reload.year
  end

  test "super_admin can update payment_amount" do
    sign_in @admin
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { payment_amount: 750.00 }
    }
    assert_redirected_to admin_pipeline_path
    assert_equal 750.00, @request_record.reload.payment_amount.to_f
  end

  test "partial checklist update preserves other keys" do
    sign_in @admin
    # First set sol=true
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { document_checklist: { sol: "true" } }
    }
    # Then set vol=true (sol should remain true)
    patch admin_pipeline_update_path(@request_record), params: {
      homologation_request: { document_checklist: { vol: "true" } }
    }
    checklist = @request_record.reload.document_checklist
    assert_equal true, checklist["sol"], "sol should be preserved from first update"
    assert_equal true, checklist["vol"]
    assert_equal 10, checklist.size, "all 10 keys should be present"
  end

  # === Card JSON structure ===

  test "pipeline card contains expected fields" do
    sign_in @admin
    get admin_pipeline_path
    cards = inertia.props[:stages]["pago_recibido"]
    assert cards.any?, "Expected at least one card in pago_recibido"
    card = cards.first
    expected_keys = %i[id studentName country identityCard year serviceType amount
                       pipelineStage pipelineNotes documentChecklist documentsComplete
                       documentsTotal cotejoRoute countryMissing updatedAt canAdvance
                       canRetreat nextStageName requiresTranslation]
    expected_keys.each do |key|
      assert card.key?(key), "Card missing key: #{key}"
    end
  end
end
