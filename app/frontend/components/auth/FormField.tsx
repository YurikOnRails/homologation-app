import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

interface FormFieldProps {
  id: string
  label?: string
  type?: string
  autoComplete?: string
  placeholder?: string
  value: string
  onChange: (value: string) => void
  error?: string | string[]
  required?: boolean
}

export function FormField({
  id,
  label,
  type = "text",
  autoComplete,
  placeholder,
  value,
  onChange,
  error,
  required,
}: FormFieldProps) {
  return (
    <div className="space-y-2">
      {label && <Label htmlFor={id}>{label}</Label>}
      <Input
        id={id}
        type={type}
        autoComplete={autoComplete}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        required={required}
      />
      {error && <p className="text-xs text-destructive">{error}</p>}
    </div>
  )
}
