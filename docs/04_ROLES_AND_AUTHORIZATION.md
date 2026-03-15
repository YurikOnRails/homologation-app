# Roles & Authorization (Pundit)

## Roles

| Role          | Description                                                    |
|---------------|----------------------------------------------------------------|
| `super_admin` | Full system access. Manages coordinators, teachers, views all data |
| `coordinator` | Manages homologation requests. Chats with students. Downloads docs |
| `teacher`     | Read-only view of assigned students' requests                  |
| `student`     | Submits requests, uploads documents, chats with coordinator    |
| `family`      | Read-only view of linked student's requests                    |

## Permission Matrix

| Action                         | super_admin | coordinator | teacher | student | family |
|--------------------------------|:-----------:|:-----------:|:-------:|:-------:|:------:|
| View admin dashboard           |      +      |      -      |    -    |    -    |    -   |
| Manage users (CRUD)            |      +      |      -      |    -    |    -    |    -   |
| Assign roles                   |      +      |      -      |    -    |    -    |    -   |
| View all requests              |      +      |      +      |    -    |    -    |    -   |
| View assigned student requests |      +      |      +      |    +    |    -    |    +   |
| View own requests              |      +      |      +      |    +    |    +    |    +   |
| Submit new request             |      -      |      -      |    -    |    +    |    -   |
| Edit own request (draft)       |      -      |      -      |    -    |    +    |    -   |
| Change request status          |      +      |      +      |    -    |    -    |    -   |
| Assign coordinator to request  |      +      |      +      |    -    |    -    |    -   |
| Send chat message              |      +      |      +      |    -    |    +    |    -   |
| Read chat messages             |      +      |      +      |    +    |    +    |    +   |
| Upload documents               |      +      |      +      |    -    |    +    |    -   |
| Download documents             |      +      |      +      |    +    |    -    |    -   |
| View reports/charts            |      +      |      +      |    -    |    -    |    -   |
| Export data (CSV)              |      +      |      -      |    -    |    -    |    -   |
| AmoCRM settings                |      +      |      -      |    -    |    -    |    -   |

## Implementation

### Gem
```ruby
# Gemfile
gem "pundit"
```

### User Model Helpers
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  def has_role?(role_name)
    roles.exists?(name: role_name)
  end

  def super_admin?  = has_role?("super_admin")
  def coordinator?  = has_role?("coordinator")
  def teacher?      = has_role?("teacher")
  def student?      = has_role?("student")
  def family?       = has_role?("family")
end
```

### Example Policy
```ruby
# app/policies/homologation_request_policy.rb
class HomologationRequestPolicy < ApplicationPolicy
  def index?
    user.super_admin? || user.coordinator? || user.student? || user.teacher? || user.family?
  end

  def show?
    user.super_admin? ||
      record.user_id == user.id ||
      record.coordinator_id == user.id ||
      user.teacher? && assigned_student?(record.user) ||
      user.family? && linked_student?(record.user)
  end

  def create?
    user.student?
  end

  def update?
    user.super_admin? || record.coordinator_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.super_admin? || user.coordinator?
        scope.all
      elsif user.student?
        scope.where(user_id: user.id)
      elsif user.teacher?
        scope.where(user_id: user.assigned_student_ids)
      elsif user.family?
        scope.where(user_id: user.linked_student_ids)
      else
        scope.none
      end
    end
  end
end
```

### Controller Integration
```ruby
# app/controllers/inertia_controller.rb
class InertiaController < ApplicationController
  include Pundit::Authorization

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  rescue_from Pundit::NotAuthorizedError do |_exception|
    redirect_to root_path, alert: "You are not authorized to perform this action."
  end
end
```

### Shared Inertia Data (for frontend role checks)
```ruby
# config/initializers/inertia_rails.rb
InertiaRails.configure do |config|
  config.shared_data = lambda { |controller|
    {
      current_user: controller.current_user&.then { |u|
        {
          id: u.id,
          name: u.name,
          email: u.email,
          roles: u.roles.pluck(:name),
          avatar_url: u.avatar_url
        }
      },
      flash: controller.flash.to_h,
      unread_notifications_count: controller.current_user&.notifications&.unread&.count || 0
    }
  }
end
```

### Frontend Role Guard (React)
```tsx
// app/frontend/components/RoleGuard.tsx
import { usePage } from "@inertiajs/react"

type Props = {
  roles: string[]
  children: React.ReactNode
  fallback?: React.ReactNode
}

export function RoleGuard({ roles, children, fallback = null }: Props) {
  const { current_user } = usePage().props as any
  const hasRole = current_user?.roles?.some((r: string) => roles.includes(r))
  return hasRole ? <>{children}</> : <>{fallback}</>
}
```
