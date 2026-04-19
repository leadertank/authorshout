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

## Default Admin Account (Development)

- Email: admin@authorshout.local
- Password: Password123!

You can log in with this account to access:

- `/admin/dashboard`
- `/admin/users`

## Forms And PayPal Sandbox Setup

The app now includes an admin-only form builder with free, one-time, and subscription payment modes.

After running `bin/rails db:seed`, two sample forms are available:

- `/forms/author-strategy-call` for one-time payments
- `/forms/book-marketing-retainer` for subscription payments

To test PayPal checkout in development, export sandbox credentials before starting Rails:

```bash
export PAYPAL_ENV=sandbox
export PAYPAL_CLIENT_ID=your_sandbox_client_id
export PAYPAL_CLIENT_SECRET=your_sandbox_client_secret
```

For subscription forms, create a PayPal sandbox billing plan and paste its plan ID into the form's `PayPal plan ID` field in the admin builder.

To keep recurring and off-session payment state in sync, also configure a PayPal webhook ID:

```bash
export PAYPAL_WEBHOOK_ID=your_paypal_webhook_id
```

Point the PayPal sandbox webhook at:

```text
POST /webhooks/paypal
```

Recommended PayPal webhook events to subscribe to:

- `PAYMENT.CAPTURE.COMPLETED`
- `PAYMENT.CAPTURE.DENIED`
- `BILLING.SUBSCRIPTION.ACTIVATED`
- `BILLING.SUBSCRIPTION.RE-ACTIVATED`
- `BILLING.SUBSCRIPTION.CANCELLED`
- `BILLING.SUBSCRIPTION.SUSPENDED`
- `BILLING.SUBSCRIPTION.EXPIRED`
- `BILLING.SUBSCRIPTION.PAYMENT.COMPLETED`
- `BILLING.SUBSCRIPTION.PAYMENT.FAILED`

Recommended sandbox flow:

1. Create a PayPal sandbox app to get client credentials.
2. Start Rails with the exported variables above.
3. Log in as the admin user and open `/admin/forms`.
4. Test `/forms/author-strategy-call` for one-time checkout.
5. Replace the placeholder plan ID on `/forms/book-marketing-retainer` and test subscription checkout.

## Notes For Future Premium/Plus Tier

The free tier is currently enforced as one book per profile. This can later be expanded for premium members by introducing a membership plan model and changing the one-book rule to a plan-based limit.
