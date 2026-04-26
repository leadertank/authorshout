import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template", "addBtn"]
  static values = { bookCount: Number }

  connect() {
    this.bookCountValue = document.querySelectorAll('.book-entry').length - 1 // exclude template
  }

  addBook(e) {
    e.preventDefault()
    
    // Clone the template
    const template = this.templateTarget
    const clone = template.content.cloneNode(true)
    
    // Update the legend with incrementing number
    this.bookCountValue += 1
    const legend = clone.querySelector('.book-entry-legend')
    if (legend) {
      legend.textContent = `Book ${this.bookCountValue + 1}` // +1 because featured is book 1
    }

    // Update field names to include the index
    const inputs = clone.querySelectorAll('input, textarea')
    inputs.forEach(input => {
      if (input.name) {
        // Replace the [0] index with the new index
        input.name = input.name.replace(/\[\d+\]/, `[${this.bookCountValue}]`)
      }
    })

    // Add remove event listener to the remove button
    const removeBtn = clone.querySelector('.remove-book-btn')
    if (removeBtn) {
      removeBtn.addEventListener('click', (e) => this.removeBook(e))
    }

    // Add the new entry to the container
    this.containerTarget.appendChild(clone)
  }

  removeBook(e) {
    e.preventDefault()
    
    const bookEntry = e.target.closest('.book-entry')
    
    // If this is an existing book (has an ID field), mark it for deletion
    const idField = bookEntry.querySelector('input[id*="_id"]')
    if (idField && idField.value) {
      // Mark for deletion instead of removing the DOM element
      const destroyField = bookEntry.querySelector('.destroy-field')
      if (destroyField) {
        destroyField.value = true
        bookEntry.style.display = 'none'
      }
    } else {
      // New book entry, just remove it
      bookEntry.remove()
      this.bookCountValue -= 1
    }
  }
}
