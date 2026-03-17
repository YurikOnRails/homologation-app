import { cn } from "@/lib/utils"

type MainProps = React.HTMLAttributes<HTMLDivElement> & {
  fixed?: boolean
}

export function Main({ fixed, className, ...props }: MainProps) {
  return (
    <div
      className={cn(
        fixed && "flex flex-1 flex-col overflow-hidden min-h-0",
        className
      )}
      {...props}
    />
  )
}
