// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const setupMobileNavJump = () => {
	document.querySelectorAll("[data-nav-jump]").forEach((select) => {
		if (select.dataset.navJumpBound === "true") return
		select.dataset.navJumpBound = "true"

		select.addEventListener("change", () => {
			const destination = select.value
			if (!destination) return
			window.location.href = destination
		})
	})
}

const setupCopyButtons = () => {
	document.querySelectorAll(".copy-link-button").forEach((button) => {
		if (button.dataset.copyBound === "true") return
		button.dataset.copyBound = "true"

		button.addEventListener("click", async () => {
			const copyUrl = button.dataset.copyUrl
			if (!copyUrl) return

			try {
				await navigator.clipboard.writeText(copyUrl)
				button.textContent = "Copied"
				setTimeout(() => {
					button.textContent = "Copy Link"
				}, 1200)
			} catch (_error) {
				button.textContent = "Unable to copy"
			}
		})
	})
}

document.addEventListener("turbo:load", () => {
	setupMobileNavJump()
	setupCopyButtons()
})

import "trix"
import "@rails/actiontext"
