class AddPipelineFieldsToHomologationRequests < ActiveRecord::Migration[8.1]
  def change
    add_column :homologation_requests, :pipeline_stage, :string
    add_column :homologation_requests, :pipeline_notes, :text
    add_column :homologation_requests, :document_checklist, :json, default: {}
    add_column :homologation_requests, :year, :integer
    add_index  :homologation_requests, :pipeline_stage
  end
end
