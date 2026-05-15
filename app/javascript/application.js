// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const setupMobileNav = () => {
	document.querySelectorAll("[data-nav-toggle]").forEach((toggleButton) => {
		if (toggleButton.dataset.mobileNavBound === "true") return

		const navRow = toggleButton.closest(".nav-row")
		const mainNav = navRow?.querySelector("[data-main-nav]") || document.querySelector("[data-main-nav]")
		if (!mainNav) return

		toggleButton.dataset.mobileNavBound = "true"
		toggleButton.setAttribute("aria-expanded", mainNav.classList.contains("open") ? "true" : "false")

		toggleButton.addEventListener("click", () => {
			const isOpen = mainNav.classList.toggle("open")
			toggleButton.setAttribute("aria-expanded", isOpen ? "true" : "false")
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
	setupMobileNav()
	setupCopyButtons()
})

document.addEventListener("turbo:before-cache", () => {
	document.querySelectorAll("[data-main-nav]").forEach((mainNav) => {
		mainNav.classList.remove("open")
	})

	document.querySelectorAll("[data-nav-toggle]").forEach((toggleButton) => {
		toggleButton.setAttribute("aria-expanded", "false")
	})
})

import "trix"
import "@rails/actiontext"
