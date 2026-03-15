# Routes & API

## Routes Structure

All routes serve Inertia responses (HTML + JSON page data). No separate REST API needed thanks to Inertia.js protocol.

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # ─── Health ───
  get "up" => "rails/health#show", as: :rails_health_check

  # ─── Authentication ───
  resource  :session,      only: [:new, :create, :destroy]
  resource  :registration, only: [:new, :create]
  resources :passwords,    param: :token, only: [:new, :create, :edit, :update]

  # OAuth
  post "/auth/:provider/callback", to: "auth/omniauth_callbacks#create"
  get  "/auth/:provider/callback", to: "auth/omniauth_callbacks#create"
  get  "/auth/failure",            to: "auth/omniauth_callbacks#failure"

  # ─── Authenticated Routes ───
  # All routes below require authentication

  # Dashboard (home page after login)
  root "dashboard#index"

  # Profile
  resource :profile, only: [:edit, :update]

  # Homologation Requests
  resources :homologation_requests, path: "requests" do
    # Nested: messages within request's conversation
    resources :messages, only: [:create]

    # Download specific document
    member do
      get :download_document  # ?document_id=X
    end
  end

  # Notifications
  resources :notifications, only: [:index, :update] do
    collection do
      post :mark_all_read
    end
  end

  # ─── Admin ───
  namespace :admin do
    root "dashboard#index"

    # Dashboard with stats
    get "dashboard", to: "dashboard#index"

    # User management
    resources :users do
      member do
        post :assign_role
        delete :remove_role
      end
    end

    # Reports
    resources :reports, only: [:index] do
      collection do
        get :requests_by_status
        get :requests_over_time
        get :response_times
      end
    end
  end

  # ─── Action Cable ───
  # WebSocket endpoint (auto-configured)
  # mount ActionCable.server => "/cable"  # Already in cable.yml
end
```

## Controller Actions Detail

### SessionsController (built-in + extended)
| Method | Path              | Action  | Description           |
|--------|-------------------|---------|-----------------------|
| GET    | /session/new      | new     | Login page            |
| POST   | /session          | create  | Login                 |
| DELETE | /session          | destroy | Logout                |

### RegistrationsController
| Method | Path               | Action | Description            |
|--------|--------------------|--------|------------------------|
| GET    | /registration/new  | new    | Signup page            |
| POST   | /registration      | create | Create account         |

### HomologationRequestsController
| Method | Path                      | Action  | Description                    |
|--------|---------------------------|---------|--------------------------------|
| GET    | /requests                 | index   | List requests (filtered by role)|
| GET    | /requests/new             | new     | Submit request form            |
| POST   | /requests                 | create  | Create request                 |
| GET    | /requests/:id             | show    | Request detail + chat + files  |
| PATCH  | /requests/:id             | update  | Update status / assign coord.  |
| GET    | /requests/:id/download_document | download_document | Download a file   |

### MessagesController
| Method | Path                            | Action | Description        |
|--------|---------------------------------|--------|--------------------|
| POST   | /requests/:request_id/messages  | create | Send chat message  |

*Messages are loaded as part of the request show page. New messages arrive via Action Cable.*

### NotificationsController
| Method | Path                       | Action        | Description        |
|--------|----------------------------|---------------|--------------------|
| GET    | /notifications             | index         | List notifications |
| PATCH  | /notifications/:id         | update        | Mark as read       |
| POST   | /notifications/mark_all_read | mark_all_read | Mark all read    |

### Admin::DashboardController
| Method | Path             | Action | Description              |
|--------|------------------|--------|--------------------------|
| GET    | /admin           | index  | Dashboard with stats     |

### Admin::UsersController
| Method | Path                          | Action      | Description        |
|--------|-------------------------------|-------------|--------------------|
| GET    | /admin/users                  | index       | List all users     |
| GET    | /admin/users/new              | new         | New user form      |
| POST   | /admin/users                  | create      | Create user        |
| GET    | /admin/users/:id              | show        | User detail        |
| GET    | /admin/users/:id/edit         | edit        | Edit user form     |
| PATCH  | /admin/users/:id              | update      | Update user        |
| DELETE | /admin/users/:id              | destroy     | Deactivate user    |
| POST   | /admin/users/:id/assign_role  | assign_role | Add role to user   |
| DELETE | /admin/users/:id/remove_role  | remove_role | Remove role        |

### Admin::ReportsController
| Method | Path                             | Action             | Description          |
|--------|----------------------------------|--------------------|----------------------|
| GET    | /admin/reports                   | index              | Reports page         |
| GET    | /admin/reports/requests_by_status| requests_by_status | JSON data for chart  |
| GET    | /admin/reports/requests_over_time| requests_over_time | JSON data for chart  |
| GET    | /admin/reports/response_times    | response_times     | JSON data for chart  |

## Action Cable Channels

### ConversationChannel
```ruby
# Subscribe: { channel: "ConversationChannel", conversation_id: 123 }
# Broadcasts: new messages as JSON
```

### NotificationChannel
```ruby
# Subscribe: { channel: "NotificationChannel" }
# Broadcasts: new notification for current_user
```

## Inertia Shared Data (every request)

```json
{
  "current_user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "roles": ["student"],
    "avatar_url": "https://..."
  },
  "flash": {
    "notice": "...",
    "alert": "..."
  },
  "unread_notifications_count": 3
}
```
