// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener("turbo:load", () => {
	const toggleButton = document.querySelector("[data-nav-toggle]")
	const mainNav = document.querySelector("[data-main-nav]")

	if (toggleButton && mainNav) {
		toggleButton.addEventListener("click", () => {
			mainNav.classList.toggle("open")
		})
	}

	document.querySelectorAll(".copy-link-button").forEach((button) => {
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
})
