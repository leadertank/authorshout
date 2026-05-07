import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "slide", "prev", "next"]

  connect() {
    this.currentIndex = 0
    this.update()
  }

  prev() {
    if (this.slideTargets.length <= 1) return

    this.currentIndex = (this.currentIndex - 1 + this.slideTargets.length) % this.slideTargets.length
    this.update()
  }

  next() {
    if (this.slideTargets.length <= 1) return

    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length
    this.update()
  }

  update() {
    if (!this.hasTrackTarget) return

    this.trackTarget.style.transform = `translateX(-${this.currentIndex * 100}%)`

    const hasMultipleSlides = this.slideTargets.length > 1
    if (this.hasPrevTarget) this.prevTarget.disabled = !hasMultipleSlides
    if (this.hasNextTarget) this.nextTarget.disabled = !hasMultipleSlides
  }
}