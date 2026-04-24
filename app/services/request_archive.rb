# Builds a ZIP archive of all attached files for a HomologationRequest.
#
# Empty categories are skipped — no blank folders in the archive, so
# super_admin can see at a glance what the student actually uploaded.
class RequestArchive
  def initialize(request)
    @request = request
  end

  # Returns the ZIP file as a binary (ASCII-8BIT) string.
  def build
    buffer = Zip::OutputStream.write_buffer do |zip|
      zip.put_next_entry("README.txt")
      zip.write(readme)

      if @request.application.attached?
        write_attachment(zip, @request.application.attachment, "01_application")
      end
      @request.originals_attachments.each { |att| write_attachment(zip, att, "02_originals") }
      @request.documents_attachments.each { |att| write_attachment(zip, att, "03_documents") }
    end
    buffer.rewind
    buffer.read
  end

  # ASCII filename — Cyrillic/diacritics break on some Windows unzip tools.
  # Full name (not just last) so super_admin spots the right archive at a glance in Downloads.
  def filename
    # Russian rules in config/locales/transliterate.ru.yml + default I18n rules for Latin accents.
    ascii = I18n.transliterate(@request.user.name.to_s, locale: :ru)
                .gsub(/[^A-Za-z0-9]+/, "_")
                .gsub(/\A_+|_+\z/, "")
    ascii = "student" if ascii.empty?
    "#{ascii}_Request_#{@request.id}.zip"
  end

  private

  def write_attachment(zip, attachment, folder)
    zip.put_next_entry("#{folder}/#{attachment.filename}")
    zip.write(attachment.blob.download)
  end

  def readme
    submitted = @request.created_at.utc.strftime("%Y-%m-%d %H:%M UTC")
    <<~TXT
      Homologation Request ##{@request.id}

      Student:   #{@request.user.name}
      Email:     #{@request.user.email_address}
      Request ID: #{@request.id}
      Service:   #{@request.service_type}
      Status:    #{@request.status}
      Submitted: #{submitted}
    TXT
  end
end
