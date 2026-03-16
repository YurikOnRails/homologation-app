module RequestSerializer
  def request_list_json(r)
    { id: r.id, subject: r.subject, serviceType: r.service_type,
      status: r.status, createdAt: r.created_at.iso8601,
      updatedAt: r.updated_at.iso8601, user: { id: r.user.id, name: r.user.name } }
  end
end
