import { useCallback, useState } from "react"
import { useDropzone, type FileRejection } from "react-dropzone"
import { DirectUpload } from "@rails/activestorage"
import { useTranslation } from "react-i18next"
import { X, Upload } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

// Keep in sync with HomologationRequest::ALLOWED_UPLOAD_TYPES / MAX_UPLOAD_SIZE.
const MAX_SIZE_MB = 15
const MAX_SIZE_BYTES = MAX_SIZE_MB * 1024 * 1024
const ACCEPT = {
  "application/pdf": [".pdf"],
  "image/jpeg": [".jpg", ".jpeg"],
  "image/png": [".png"],
  "image/webp": [".webp"],
}

interface UploadedFile {
  name: string
  signedId: string
}

interface FileDropZoneProps {
  name: string
  multiple: boolean
  onUpload: (signedIds: string[]) => void
  // Rails sends errors[:documents] as an array of messages (one per invalid attachment).
  error?: string | string[]
}

export function FileDropZone({ name, multiple, onUpload, error: serverError }: FileDropZoneProps) {
  const { t } = useTranslation()
  const [uploaded, setUploaded] = useState<UploadedFile[]>([])
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState(0)
  const [uploadError, setUploadError] = useState<string | null>(null)
  const [rejections, setRejections] = useState<FileRejection[]>([])

  const uploadFile = useCallback(
    (file: File): Promise<string> => {
      return new Promise((resolve, reject) => {
        const upload = new DirectUpload(
          file,
          "/rails/active_storage/direct_uploads",
          {
            directUploadWillStoreFileWithXHR: (xhr) => {
              xhr.upload.addEventListener("progress", (event) => {
                if (event.lengthComputable) {
                  setProgress(Math.round((event.loaded / event.total) * 100))
                }
              })
            },
          }
        )
        upload.create((err, blob) => {
          if (err || !blob) {
            reject(err ?? new Error("Upload failed"))
          } else {
            resolve(blob.signed_id)
          }
        })
      })
    },
    []
  )

  const onDrop = useCallback(
    async (acceptedFiles: File[], fileRejections: FileRejection[]) => {
      setRejections(fileRejections)
      if (!acceptedFiles.length) return
      setUploading(true)
      setUploadError(null)
      setProgress(0)
      try {
        const newUploaded: UploadedFile[] = []
        for (const file of acceptedFiles) {
          const signedId = await uploadFile(file)
          newUploaded.push({ name: file.name, signedId })
        }
        const allUploaded = multiple ? [...uploaded, ...newUploaded] : newUploaded
        setUploaded(allUploaded)
        onUpload(allUploaded.map((f) => f.signedId))
      } catch {
        setUploadError(t("common.error"))
      } finally {
        setUploading(false)
        setProgress(0)
      }
    },
    [uploadFile, uploaded, multiple, onUpload, t]
  )

  const removeFile = (signedId: string) => {
    const updated = uploaded.filter((f) => f.signedId !== signedId)
    setUploaded(updated)
    onUpload(updated.map((f) => f.signedId))
  }

  const translateRejection = (rejection: FileRejection): string => {
    const code = rejection.errors[0]?.code
    if (code === "file-too-large") {
      return t("requests.form.file_too_large", { name: rejection.file.name, size: MAX_SIZE_MB })
    }
    if (code === "file-invalid-type") {
      return t("requests.form.file_type_not_supported", { name: rejection.file.name })
    }
    return rejection.errors[0]?.message ?? t("common.error")
  }

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    multiple,
    maxSize: MAX_SIZE_BYTES,
    accept: ACCEPT,
  })

  const hasError = Boolean(serverError) || rejections.length > 0 || Boolean(uploadError)

  return (
    <div className="space-y-2">
      <div
        {...getRootProps()}
        className={cn(
          "border-2 border-dashed rounded-lg p-4 text-center cursor-pointer transition-colors min-h-[80px] flex items-center justify-center",
          isDragActive
            ? "border-primary bg-primary/5"
            : hasError
              ? "border-destructive/60"
              : "border-muted-foreground/25 hover:border-primary/50"
        )}
      >
        <input {...getInputProps()} name={name} />
        <div className="flex flex-col items-center gap-2 text-sm text-muted-foreground">
          <Upload className="h-5 w-5" />
          <span>
            {multiple
              ? t("requests.form.drop_files")
              : t("requests.form.drop_file")}
          </span>
          <span className="text-xs">
            {t("requests.form.file_constraints", { size: MAX_SIZE_MB })}
          </span>
        </div>
      </div>

      {uploading && (
        <div className="w-full bg-muted rounded-full h-2">
          <div
            className="bg-primary h-2 rounded-full transition-all"
            style={{ width: `${progress}%` }}
          />
        </div>
      )}

      {rejections.length > 0 && (
        <ul className="space-y-1" role="alert">
          {rejections.map((rejection, i) => (
            <li
              key={`${rejection.file.name}-${i}`}
              className="text-sm text-destructive"
            >
              {translateRejection(rejection)}
            </li>
          ))}
        </ul>
      )}

      {uploadError && <p className="text-sm text-destructive">{uploadError}</p>}
      {serverError && (
        <p className="text-sm text-destructive">
          {Array.isArray(serverError) ? serverError.join(", ") : serverError}
        </p>
      )}

      {uploaded.length > 0 && (
        <ul className="space-y-1">
          {uploaded.map((file) => (
            <li
              key={file.signedId}
              className="flex items-center justify-between text-sm bg-muted rounded px-3 py-2"
            >
              <span className="truncate">{file.name}</span>
              <Button
                type="button"
                variant="ghost"
                size="sm"
                className="h-6 w-6 p-0 ml-2 flex-shrink-0"
                onClick={() => removeFile(file.signedId)}
              >
                <X className="h-4 w-4" />
              </Button>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
