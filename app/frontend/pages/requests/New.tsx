import { useForm, usePage } from "@inertiajs/react"
import { useTranslation } from "react-i18next"
import { AuthenticatedLayout } from "@/components/layout/AuthenticatedLayout"
import { FileDropZone } from "@/components/documents/FileDropZone"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Checkbox } from "@/components/ui/checkbox"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { getOptionLabel } from "@/lib/utils"
import { routes } from "@/lib/routes"
import type { SharedProps } from "@/types/index"

export default function RequestsNew() {
  const { t } = useTranslation()
  const { auth, selectOptions } = usePage<SharedProps>().props
  const locale = auth.user?.locale ?? "es"

  const { data, setData, post, processing, errors } = useForm({
    subject: "",
    service_type: "",
    description: "",
    identity_card: "",
    passport: "",
    education_system: "",
    studies_finished: "",
    study_type_spain: "",
    studies_spain: "",
    university: "",
    language_knowledge: "",
    language_certificate: "",
    referral_source: "",
    privacy_accepted: false,
    application: [] as string[],
    originals: [] as string[],
    documents: [] as string[],
    commit: "",
  })

  const handleSubmit = (commitValue: "submit" | "draft") => {
    setData("commit", commitValue)
    post(routes.requests)
  }

  return (
    <AuthenticatedLayout>
      <div className="max-w-2xl mx-auto space-y-6">
        <h1 className="text-2xl font-bold">{t("requests.new_request")}</h1>

        <form
          onSubmit={(e) => {
            e.preventDefault()
            handleSubmit("submit")
          }}
          className="space-y-6"
        >
          {/* Section: About You */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                {t("requests.form.section_about")}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>{t("requests.form.name")}</Label>
                <Input value={auth.user?.name ?? ""} disabled />
              </div>
            </CardContent>
          </Card>

          {/* Section: Your Request */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                {t("requests.form.section_request")}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="service_type">
                  {t("requests.form.service_type")} *
                </Label>
                <Select
                  value={data.service_type}
                  onValueChange={(v) => setData("service_type", v)}
                >
                  <SelectTrigger id="service_type">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.service_types ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {errors.service_type && (
                  <p className="text-sm text-destructive">{errors.service_type}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="subject">
                  {t("requests.form.subject")} *
                </Label>
                <Input
                  id="subject"
                  value={data.subject}
                  onChange={(e) => setData("subject", e.target.value)}
                />
                {errors.subject && (
                  <p className="text-sm text-destructive">{errors.subject}</p>
                )}
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">{t("requests.form.description")}</Label>
                <Textarea
                  id="description"
                  value={data.description}
                  onChange={(e) => setData("description", e.target.value)}
                  placeholder={t("requests.form.description_hint")}
                  rows={4}
                />
              </div>
            </CardContent>
          </Card>

          {/* Section: Education */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                {t("requests.form.section_education")}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>{t("requests.form.identity_card")}</Label>
                <Input
                  value={data.identity_card}
                  onChange={(e) => setData("identity_card", e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.passport")}</Label>
                <Input
                  value={data.passport}
                  onChange={(e) => setData("passport", e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.education_system")}</Label>
                <Select
                  value={data.education_system}
                  onValueChange={(v) => setData("education_system", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.education_systems ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.studies_finished")}</Label>
                <Select
                  value={data.studies_finished}
                  onValueChange={(v) => setData("studies_finished", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.studies_finished ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.study_type_spain")}</Label>
                <Select
                  value={data.study_type_spain}
                  onValueChange={(v) => setData("study_type_spain", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.study_types_spain ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.studies_spain")}</Label>
                <Input
                  value={data.studies_spain}
                  onChange={(e) => setData("studies_spain", e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.university")}</Label>
                <Select
                  value={data.university}
                  onValueChange={(v) => setData("university", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.universities ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Section: Optional */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                {t("requests.form.section_optional")}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>{t("requests.form.language_level")}</Label>
                <Select
                  value={data.language_knowledge}
                  onValueChange={(v) => setData("language_knowledge", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.language_levels ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.language_certificate")}</Label>
                <Select
                  value={data.language_certificate}
                  onValueChange={(v) => setData("language_certificate", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.language_certificates ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.referral_source")}</Label>
                <Select
                  value={data.referral_source}
                  onValueChange={(v) => setData("referral_source", v)}
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {(selectOptions.referral_sources ?? []).map((opt) => (
                      <SelectItem key={opt.key} value={opt.key}>
                        {getOptionLabel(opt, locale)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </CardContent>
          </Card>

          {/* Section: Documents */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">
                {t("requests.form.section_documents")}
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="space-y-2">
                <Label>{t("requests.form.application_file")}</Label>
                <FileDropZone
                  name="homologation_request[application][]"
                  multiple={false}
                  onUpload={(ids) => setData("application", ids)}
                />
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.originals_files")}</Label>
                <FileDropZone
                  name="homologation_request[originals][]"
                  multiple={true}
                  onUpload={(ids) => setData("originals", ids)}
                />
              </div>
              <div className="space-y-2">
                <Label>{t("requests.form.other_files")}</Label>
                <FileDropZone
                  name="homologation_request[documents][]"
                  multiple={true}
                  onUpload={(ids) => setData("documents", ids)}
                />
              </div>
            </CardContent>
          </Card>

          {/* Privacy + Submit */}
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <Checkbox
                id="privacy_accepted"
                checked={data.privacy_accepted}
                onCheckedChange={(checked) =>
                  setData("privacy_accepted", checked === true)
                }
                className="mt-0.5"
              />
              <Label htmlFor="privacy_accepted" className="text-sm leading-relaxed cursor-pointer">
                {t("requests.form.privacy_policy")}
              </Label>
            </div>
            {errors.privacy_accepted && (
              <p className="text-sm text-destructive">{errors.privacy_accepted}</p>
            )}

            <div className="flex flex-col gap-3 sm:flex-row">
              <Button
                type="submit"
                disabled={processing}
                className="min-h-[44px] flex-1 sm:flex-none"
              >
                {t("requests.submit_request")}
              </Button>
              <Button
                type="button"
                variant="outline"
                disabled={processing}
                className="min-h-[44px] flex-1 sm:flex-none"
                onClick={() => handleSubmit("draft")}
              >
                {t("requests.save_draft")}
              </Button>
            </div>
          </div>
        </form>
      </div>
    </AuthenticatedLayout>
  )
}
