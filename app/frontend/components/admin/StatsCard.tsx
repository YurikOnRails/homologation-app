import { ReactNode } from "react"
import { Link } from "@inertiajs/react"
import { Card, CardContent } from "@/components/ui/card"
import { cn } from "@/lib/utils"

interface StatsCardProps {
  icon: ReactNode
  label: string
  value: number | string
  className?: string
  href?: string
}

export function StatsCard({ icon, label, value, className, href }: StatsCardProps) {
  const Wrapper = href ? Link : "div"
  const wrapperProps = href ? { href } : {}

  return (
    <Card className={cn(className, href && "hover:shadow-md transition-shadow cursor-pointer")}>
      <Wrapper {...wrapperProps}>
        <CardContent className="flex items-center gap-4 p-4 sm:p-6">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary shrink-0">
            {icon}
          </div>
          <div className="min-w-0">
            <p className="text-sm text-muted-foreground truncate">{label}</p>
            <p className="text-2xl font-bold">{value}</p>
          </div>
        </CardContent>
      </Wrapper>
    </Card>
  )
}
