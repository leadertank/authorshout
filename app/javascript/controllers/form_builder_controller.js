import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = ["list", "template"]

  connect() {
    this.sortable = Sortable.create(this.listTarget, {
      animation: 150,
      handle: ".form-builder-field-drag",
      onEnd: () => this.syncPositions()
    })

    this.syncPositions()
  }

  disconnect() {
    this.sortable?.destroy()
  }

  addField(event) {
    event.preventDefault()

    const fieldType = event.params.fieldType || "text"
    const uniqueId = `${Date.now()}-${Math.floor(Math.random() * 1000)}`
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", uniqueId)
    const wrapper = document.createElement("div")
    wrapper.innerHTML = html.trim()

    const fieldNode = wrapper.firstElementChild
    const typeSelect = fieldNode.querySelector('[name*="[field_type]"]')
    const labelInput = fieldNode.querySelector('[name*="[label]"]')
    const identifierInput = fieldNode.querySelector('[name*="[identifier]"]')
    const title = fieldNode.querySelector(".form-builder-field-title")

    if (typeSelect) typeSelect.value = fieldType
    if (labelInput) labelInput.value = this.defaultLabel(fieldType)
    if (identifierInput) identifierInput.value = this.defaultIdentifier(fieldType)
    if (title) title.textContent = this.defaultLabel(fieldType)
    fieldNode.dataset.fieldType = fieldType

    this.listTarget.appendChild(fieldNode)
    this.syncPositions()
  }

  removeField(event) {
    event.preventDefault()

    const fieldNode = event.currentTarget.closest(".form-builder-field")
    if (!fieldNode) return

    const destroyInput = fieldNode.querySelector('input[name*="[_destroy]"]')
    if (destroyInput) {
      destroyInput.value = "1"
      fieldNode.remove()
    } else {
      fieldNode.remove()
    }

    this.syncPositions()
  }

  toggleSettings(event) {
    event.preventDefault()

    const fieldNode = event.currentTarget.closest(".form-builder-field")
    const settings = fieldNode?.querySelector(".form-builder-field-settings")
    if (!settings) return

    settings.hidden = !settings.hidden
  }

  labelChanged(event) {
    const fieldNode = event.currentTarget.closest(".form-builder-field")
    const title = fieldNode?.querySelector(".form-builder-field-title")
    if (title) title.textContent = event.currentTarget.value || "New Field"
  }

  fieldTypeChanged(event) {
    const fieldNode = event.currentTarget.closest(".form-builder-field")
    if (fieldNode) fieldNode.dataset.fieldType = event.currentTarget.value
  }

  syncPositions() {
    this.listTarget.querySelectorAll(".form-builder-field").forEach((fieldNode, index) => {
      const positionInput = fieldNode.querySelector(".form-builder-position")
      if (positionInput) positionInput.value = index + 1
    })
  }

  defaultLabel(fieldType) {
    return fieldType.replace(/_/g, " ").replace(/\b\w/g, (character) => character.toUpperCase())
  }

  defaultIdentifier(fieldType) {
    return `${fieldType}_${Math.floor(Math.random() * 1000)}`
  }
}