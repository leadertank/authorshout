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

## Notes For Future Premium/Plus Tier

The free tier is currently enforced as one book per profile. This can later be expanded for premium members by introducing a membership plan model and changing the one-book rule to a plan-based limit.
