import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "addBtn"]
  static values = { bookCount: Number }

  connect() {
    this.bookCountValue = this.containerTarget.querySelectorAll(".book-entry").length
  }

  addBook(e) {
    e.preventDefault()
    
    // Clone the template
    const template = this.templateTarget
    const clone = template.content.cloneNode(true)
    
    // Update the legend with incrementing number
    this.bookCountValue += 1
    const legend = clone.querySelector(".book-entry-legend")
    if (legend) {
      legend.textContent = `Book ${this.bookCountValue}`
    }

    // Replace placeholder index for nested attributes.
    const inputs = clone.querySelectorAll("input, textarea")
    inputs.forEach(input => {
      if (input.name) {
        input.name = input.name.replace(/NEW_RECORD/g, this.bookCountValue)
      }

      if (input.id) {
        input.id = input.id.replace(/NEW_RECORD/g, this.bookCountValue)
      }
    })

    const labels = clone.querySelectorAll("label")
    labels.forEach(label => {
      if (label.htmlFor) {
        label.htmlFor = label.htmlFor.replace(/NEW_RECORD/g, this.bookCountValue)
      }
    })

    // Add the new entry to the container
    this.containerTarget.appendChild(clone)
  }

  removeBook(e) {
    e.preventDefault()
    
    const bookEntry = e.target.closest(".book-entry")
    
    // If this is an existing book (has an ID field), mark it for deletion
    const idField = bookEntry.querySelector('input[id*="_id"]')
    if (idField && idField.value) {
      // Mark for deletion instead of removing the DOM element
      const destroyField = bookEntry.querySelector(".destroy-field")
      if (destroyField) {
        destroyField.value = "1"
        bookEntry.style.display = "none"
      }
    } else {
      // New book entry, just remove it
      bookEntry.remove()
    }
  }
}
