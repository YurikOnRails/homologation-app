import { Link } from "@inertiajs/react"
import { Download } from "lucide-react"
import { useTranslation } from "react-i18next"
import { formatBytes } from "@/lib/utils"
import { routes } from "@/lib/routes"
import type { FileInfo } from "@/types/pages"

interface FileListProps {
  files: FileInfo[]
  requestId: number
}

export function FileList({ files, requestId }: FileListProps) {
  const { t } = useTranslation()

  if (!files.length) return null

  return (
    <ul className="space-y-2">
      {files.map((file) => (
        <li
          key={file.id}
          className="flex items-center justify-between rounded-lg border px-3 py-2 text-sm"
        >
          <span className="truncate">{file.filename}</span>
          <div className="flex items-center gap-2 ml-2 flex-shrink-0 text-muted-foreground text-xs">
            <span>{formatBytes(file.byteSize)}</span>
            <Link
              href={routes.downloadDocument(requestId, file.id)}
              className="flex items-center gap-1 text-primary hover:underline"
            >
              <Download className="h-4 w-4" />
              <span className="sr-only">{t("common.download")}</span>
            </Link>
          </div>
        </li>
      ))}
    </ul>
  )
}
