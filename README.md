# Space for Edu

A platform for managing degree homologation, university admission, and Spanish language courses in Spain. Students submit requests, upload documents, and communicate with coordinators in real time. Data syncs to AmoCRM after payment confirmation.

---

## Demo Setup (macOS)

### Step 1 — Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2 — Install mise

[mise](https://mise.jdx.dev) manages Ruby and Node versions automatically from the project's `.mise.toml` file.

```bash
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc
```

> If you use bash instead of zsh, replace `~/.zshrc` with `~/.bash_profile`.

### Step 3 — Clone the repository

```bash
git clone <repo-url> space-for-edu
cd space-for-edu
```

### Step 4 — Install Ruby and Node

Inside the project directory, mise reads `.mise.toml` and installs the exact versions the app needs:

```bash
mise install
```

Verify:

```bash
ruby -v   # ruby 3.4.9
node -v   # v22.21.0
```

### Step 5 — Install dependencies

```bash
gem install bundler
bundle install
npm install
```

### Step 6 — Create the database and load demo data

```bash
bin/rails db:reset
```

This creates the database, runs all migrations, and populates it with realistic demo data — student requests, chat conversations, lessons, and pipeline records.

### Step 7 — Start the app

```bash
bin/rails server
```

Open **[http://localhost:3000](http://localhost:3000)** in your browser.

> Rails and the frontend build tool start together with a single command. No need for a second terminal.

---

## Demo Accounts

All accounts use the password: **`password123`**

| Role | Email | What you'll see |
|------|-------|-----------------|
| **Super Admin** | `boss@example.com` | Full dashboard — all requests, user management, reports, CRM pipeline board |
| **Coordinator** | `maria@example.com` | Student request inbox, chat, payment confirmation, pipeline |
| **Coordinator** | `carlos@example.com` | Same role, different assigned requests |
| **Teacher** | `ivan@example.com` | Lesson calendar, student chat, meeting links |
| **Student** | `ana@example.com` | Own requests, document uploads, status tracking, chat |
| **Student** | `pedro@example.com` | Same role, different request history |

To switch accounts: click your avatar in the sidebar → **Sign out**.

---

## Suggested Walkthrough

**1. Student view** — sign in as `ana@example.com`
- Browse homologation requests with real-time status tracking
- Open a request to see uploaded documents and chat history

**2. Coordinator view** — sign in as `maria@example.com`
- See all incoming student requests in the inbox
- Open a request, reply in chat, confirm a payment
- Check the CRM pipeline board (kanban with stages from payment to completion)

**3. Admin view** — sign in as `boss@example.com`
- Review the dashboard: request stats, revenue, recent activity
- Explore user management and role assignments
- Filter the pipeline board by year, service type, and verification route

**4. Teacher view** — sign in as `ivan@example.com`
- Browse the lesson calendar (week / month / list views)
- See upcoming lessons with student names and meeting links

---

## Resetting Demo Data

To restore the database to its original state at any time:

```bash
bin/rails db:reset
```

---

## Troubleshooting

**`mise install` says Ruby build failed**

Xcode command line tools are required:
```bash
xcode-select --install
mise install
```

**`bundle install` fails with a Ruby version error**

Make sure mise is active in your current terminal:
```bash
mise install
ruby -v   # should print ruby 3.4.9
```

**Port 3000 is already in use**

```bash
lsof -ti:3000 | xargs kill
bin/rails server
```

**`db:reset` fails**

```bash
rm -f storage/*.sqlite3
bin/rails db:reset
```

**Page loads but styles look broken**

The frontend compiles on the first request — wait 2–3 seconds and refresh. Happens only once after a cold start.

---

## Development Commands

```bash
bin/rails server        # Start app (Rails + Vite)
bin/rails test          # Run test suite
npm run check           # TypeScript type check
bundle exec brakeman    # Security scan
bin/rails db:reset      # Wipe and reseed database
```

## Database Backups (Production)

SQLite databases live in `storage/`. Automatic daily backups run at 3:00 AM via Solid Queue (`config/recurring.yml`), saved to `storage/backups/` with 7-day rotation.

```bash
bin/kamal backup        # Create backup on server
bin/kamal console       # Rails console inside container
bin/kamal logs          # Tail application logs
bin/kamal dbc           # SQLite console
```

Download a backup locally:
```bash
scp user@YOUR_SERVER_IP:/var/lib/docker/volumes/homologation_app_storage/_data/backups/production_*.sqlite3 ./backups/
```

## Documentation

See `docs/` for architecture, feature specs, database schema, and the implementation plan.
