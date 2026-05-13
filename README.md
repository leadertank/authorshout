# AuthorShout

AuthorShout is a Ruby on Rails platform for authors to create a free/basic member account, build an author profile, and publish one book cover + link that appears on the home discovery grid.

## Phase 1 (Free/Basic Tier)

- Devise sign up and login
- Captcha-style sign-up checkbox with label: "Check box to verify you are human"
- Member profile with:
  - Profile picture
  - Bio/description
  - One book (title + link + cover image)
  - Website link
  - Social links: X, Facebook, Instagram, Threads, Bluesky, YouTube
- Home page showing member-submitted books in submission order on a responsive multi-column grid
- Book likes from member profile and home grid (guest or signed-in users)
- Social sharing buttons: X, Pinterest, Bluesky, Threads, Reddit, Copy Link
- Admin dashboard with site analytics overview
- Admin users page with admins pinned above members

## Stack

- Ruby 3.4+
- Rails 8
- SQLite3
- Devise
- Active Storage (local)

## Setup

1. Install gems:

	```bash
	bundle install
	```

2. Prepare database and seed default admin:

	```bash
	bin/rails db:prepare
	bin/rails db:seed
	```

3. Run the app:

	```bash
	bin/rails server
	```

4. Open http://localhost:3000

## Contact Support Form

- URL: `/support`
- Fields: name, email, message
- Destination inbox: `support@authorshout.com` (configurable via `SUPPORT_INBOX_EMAIL`)

## Email Setup (SMTP, No SendGrid)

AuthorShout is configured to send mail through your own SMTP provider credentials.

Required environment variables:

- `SUPPORT_FROM_EMAIL` (example: `support@authorshout.com`)
- `SUPPORT_INBOX_EMAIL` (defaults to `support@authorshout.com`)
- `APP_HOST` (example: `authorshout.com`)
- `APP_PROTOCOL` (`https` in production)
- `SMTP_ADDRESS` (your provider SMTP host)
- `SMTP_PORT` (usually `587`)
- `SMTP_DOMAIN` (usually your domain, for example `authorshout.com`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_AUTH` (usually `plain`)
- `SMTP_STARTTLS` (`true` recommended)

Behavior by environment:

- Development: if SMTP vars are missing, emails are written to `tmp/mails`.
- Production: SMTP vars are required and used for all outbound mail.

Uses of this setup:

- Devise password reset emails
- Welcome email on account creation
- Support form emails

If you use `deliver_later` emails (for example welcome emails), run a job worker:

```bash
bin/jobs start
```

## DNS Records You Will Likely Need

Exact values come from your SMTP/mail provider, but usually include:

1. SPF TXT record on root domain
2. DKIM records (often CNAME/TXT selectors)
3. DMARC TXT record (start with monitoring mode: `p=none`)
4. MX records for the mailbox service hosting `support@authorshout.com`

Example DMARC starter value:

```txt
v=DMARC1; p=none; rua=mailto:dmarc@authorshout.com; adkim=s; aspf=s; pct=100
```

After validating delivery/authentication, move DMARC policy to `quarantine` and eventually `reject`.

## Quick Email Test

1. Visit `/support` and submit a test message.
2. Request password reset from `/users/password/new`.
3. Create a test account and confirm welcome email is sent.

## Default Admin Account (Development)

- Email: admin@authorshout.local
- Password: Password123!

You can log in with this account to access:

- `/admin/dashboard`
- `/admin/users`

## Notes For Future Premium/Plus Tier

The free tier is currently enforced as one book per profile. This can later be expanded for premium members by introducing a membership plan model and changing the one-book rule to a plan-based limit.

## Production Deploy (Manual Approval)

This repository includes a manual GitHub Actions workflow for production deploys:

- Workflow: `.github/workflows/deploy-production.yml`
- Trigger: Actions tab -> "Deploy Production (Manual)" -> Run workflow
- Deploy command used: `bundle exec kamal deploy`

### One-time GitHub setup

1. Add repository secrets in GitHub (Settings -> Secrets and variables -> Actions):

- `DEPLOY_SSH_PRIVATE_KEY` (private key matching your Droplet authorized key)
- `KAMAL_REGISTRY_PASSWORD`
- `RAILS_MASTER_KEY`
- `STRIPE_SECRET_KEY`
- `STRIPE_SIGNING_SECRET`
- `STRIPE_PAID_PRICE_ID`
- `STRIPE_AWARDS_PRICE_ID`
- `STRIPE_SOCIAL_BLITZ_PRICE_ID`
- `DO_SPACES_KEY`
- `DO_SPACES_SECRET`
- `SMTP_ADDRESS`
- `SMTP_PORT`
- `SMTP_DOMAIN`
- `SMTP_AUTH`
- `SMTP_STARTTLS`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`

2. Add environment protection for manual approval:

- Go to Settings -> Environments -> New environment: `production`
- Configure required reviewers (you)
- (Optional) Restrict deployment branches to `main`

### Recommended release flow

1. Push changes to `main`
2. Open Actions -> "Deploy Production (Manual)"
3. Click Run workflow
4. Approve the `production` environment prompt
5. Monitor logs until deploy completes

### Seed safety in production

If you run seeds in production, set `SEED_ADMIN_PASSWORD` explicitly first.
The app no longer allows production seeding with an implicit default admin password.
