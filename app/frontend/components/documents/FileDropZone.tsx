import { useCallback, useState } from "react"
import { useDropzone } from "react-dropzone"
import { DirectUpload } from "@rails/activestorage"
import { useTranslation } from "react-i18next"
import { X, Upload } from "lucide-react"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

interface UploadedFile {
  name: string
  signedId: string
}

interface FileDropZoneProps {
  name: string
  multiple: boolean
  onUpload: (signedIds: string[]) => void
}

export function FileDropZone({ name, multiple, onUpload }: FileDropZoneProps) {
  const { t } = useTranslation()
  const [uploaded, setUploaded] = useState<UploadedFile[]>([])
  const [uploading, setUploading] = useState(false)
  const [progress, setProgress] = useState(0)
  const [error, setError] = useState<string | null>(null)

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
    async (acceptedFiles: File[]) => {
      if (!acceptedFiles.length) return
      setUploading(true)
      setError(null)
      setProgress(0)
      try {
        const signedIds: string[] = []
        const newUploaded: UploadedFile[] = []
        for (const file of acceptedFiles) {
          const signedId = await uploadFile(file)
          signedIds.push(signedId)
          newUploaded.push({ name: file.name, signedId })
        }
        const allUploaded = multiple ? [...uploaded, ...newUploaded] : newUploaded
        setUploaded(allUploaded)
        onUpload(allUploaded.map((f) => f.signedId))
      } catch {
        setError(t("common.error"))
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

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    multiple,
    maxSize: 10 * 1024 * 1024,
  })

  return (
    <div className="space-y-2">
      <div
        {...getRootProps()}
        className={cn(
          "border-2 border-dashed rounded-lg p-4 text-center cursor-pointer transition-colors min-h-[80px] flex items-center justify-center",
          isDragActive
            ? "border-primary bg-primary/5"
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
            {t("requests.form.max_size", { size: 10 })}
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

      {error && <p className="text-sm text-destructive">{error}</p>}

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
