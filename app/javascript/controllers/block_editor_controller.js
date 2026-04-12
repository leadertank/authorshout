import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

const MODULE_BUTTONS = [
  { kind: "text", label: "Text" },
  { kind: "image", label: "Image" },
  { kind: "code", label: "Code" },
  { kind: "button", label: "Button" },
  { kind: "cta", label: "CTA" }
]

export default class extends Controller {
  static targets = ["board", "list", "template"]

  connect() {
    this.rowSeed = 0
    this.sortables = []
    this.rebuildBoard()
  }

  disconnect() {
    this.destroySortables()
  }

  addRow(event) {
    event.preventDefault()
    const columns = Number(event.params.columns || 1)
    const rowNumber = this.nextRowNumber()
    this.renderRow(rowNumber, columns)
    this.syncLayoutFields()
  }

  addModule(event) {
    event.preventDefault()
    const column = event.currentTarget.closest(".rc-column")
    if (!column) return

    const kind = event.params.kind || "text"
    const row = Number(column.dataset.row)
    const slot = Number(column.dataset.slot)
    const cols = Number(column.dataset.cols)

    const moduleNode = this.buildModuleNode(kind, row, slot, cols)
    column.querySelector(".rc-column-list")?.appendChild(moduleNode)
    this.refreshRow(column.closest(".rc-row"))
    this.syncLayoutFields()
  }

  remove(event) {
    event.preventDefault()
    const moduleNode = event.currentTarget.closest(".rc-module")
    if (!moduleNode) return

    const destroyInput = moduleNode.querySelector('input[name*="[_destroy]"]')
    if (destroyInput) {
      destroyInput.value = "1"
      moduleNode.remove()
    } else {
      moduleNode.remove()
    }

    const row = event.currentTarget.closest(".rc-row")
    this.refreshRow(row)
    this.syncLayoutFields()
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest(".rc-row")
    if (!row) return

    const modules = row.querySelectorAll(".rc-module")
    if (modules.length > 0) {
      const confirmed = window.confirm("This row still has modules. Remove the row and delete those modules?")
      if (!confirmed) return
      modules.forEach((moduleNode) => {
        const destroyInput = moduleNode.querySelector('input[name*="[_destroy]"]')
        if (destroyInput) destroyInput.value = "1"
      })
    }

    row.remove()
    this.syncLayoutFields()
  }

  changeRowColumns(event) {
    const row = event.currentTarget.closest(".rc-row")
    if (!row) return

    const newCols = Number(event.currentTarget.value || 1)
    row.dataset.columns = String(newCols)

    const oldModules = Array.from(row.querySelectorAll(".rc-module"))
    row.querySelectorAll(".rc-column").forEach((column) => column.remove())

    for (let slot = 1; slot <= newCols; slot += 1) {
      row.querySelector(".rc-row-columns")?.appendChild(this.buildColumnNode(row, slot, newCols))
    }

    oldModules.forEach((moduleNode) => {
      const slotInput = moduleNode.querySelector(".rc-col-input")
      let slot = Number(slotInput?.value || 1)
      if (slot > newCols) slot = newCols
      row.querySelector(`.rc-column[data-slot='${slot}'] .rc-column-list`)?.appendChild(moduleNode)
    })

    this.refreshRow(row)
    this.syncLayoutFields()
  }

  toggleSettings(event) {
    event.preventDefault()
    const moduleNode = event.currentTarget.closest(".rc-module")
    const panel = moduleNode?.querySelector(".rc-module-settings-panel")
    if (!panel) return

    panel.hidden = !panel.hidden
    event.currentTarget.classList.toggle("is-active", !panel.hidden)
  }

  kindChanged(event) {
    const moduleNode = event.currentTarget.closest(".rc-module")
    if (!moduleNode) return

    const kind = event.currentTarget.value
    moduleNode.dataset.moduleKind = kind
    const label = moduleNode.querySelector(".rc-module-kind")
    if (label) label.textContent = this.titleize(kind)
  }

  rebuildBoard() {
    this.destroySortables()
    this.boardTarget.innerHTML = ""

    const modules = this.visibleModules()
    if (modules.length === 0) {
      this.renderRow(1, 1)
      this.syncLayoutFields()
      return
    }

    const grouped = new Map()
    modules.forEach((moduleNode) => {
      const row = Number(moduleNode.querySelector(".rc-row-input")?.value || 1)
      const cols = Number(moduleNode.querySelector(".rc-cols-input")?.value || 1)
      if (!grouped.has(row)) grouped.set(row, { columns: cols, modules: [] })
      grouped.get(row).columns = cols
      grouped.get(row).modules.push(moduleNode)
    })

    Array.from(grouped.keys()).sort((a, b) => a - b).forEach((rowNumber) => {
      const data = grouped.get(rowNumber)
      const rowNode = this.renderRow(rowNumber, data.columns)

      data.modules.forEach((moduleNode) => {
        const slot = Number(moduleNode.querySelector(".rc-col-input")?.value || 1)
        const boundedSlot = Math.min(Math.max(slot, 1), data.columns)
        rowNode.querySelector(`.rc-column[data-slot='${boundedSlot}'] .rc-column-list`)?.appendChild(moduleNode)
      })

      this.refreshRow(rowNode)
    })

    this.syncLayoutFields()
  }

  renderRow(rowNumber, columns) {
    const row = document.createElement("section")
    row.className = "rc-row"
    row.dataset.row = String(rowNumber)
    row.dataset.columns = String(columns)

    row.innerHTML = `
      <header class="rc-row-header">
        <strong>Row ${rowNumber}</strong>
        <div class="rc-row-controls">
          <label>Columns</label>
          <select data-action="change->block-editor#changeRowColumns">
            ${[1, 2, 3, 4, 5].map((count) => `<option value="${count}" ${count === columns ? "selected" : ""}>${count}</option>`).join("")}
          </select>
          <button type="button" class="rc-row-remove" data-action="click->block-editor#removeRow">Remove Row</button>
        </div>
      </header>
      <div class="rc-row-columns rc-cols-${columns}"></div>
    `

    const columnsWrap = row.querySelector(".rc-row-columns")
    for (let slot = 1; slot <= columns; slot += 1) {
      columnsWrap.appendChild(this.buildColumnNode(row, slot, columns))
    }

    this.boardTarget.appendChild(row)
    this.refreshRow(row)
    return row
  }

  buildColumnNode(rowNode, slot, cols) {
    const column = document.createElement("div")
    column.className = "rc-column"
    column.dataset.row = rowNode.dataset.row
    column.dataset.slot = String(slot)
    column.dataset.cols = String(cols)

    column.innerHTML = `
      <div class="rc-column-label">Column ${slot}</div>
      <div class="rc-column-list"></div>
      <div class="rc-column-add">
        ${MODULE_BUTTONS.map((module) => `<button type="button" data-action="click->block-editor#addModule" data-block-editor-kind-param="${module.kind}">${module.label}</button>`).join("")}
      </div>
    `

    return column
  }

  buildModuleNode(kind, row, slot, cols) {
    const uniqueId = `${Date.now()}-${Math.floor(Math.random() * 1000)}`
    const html = this.templateTarget.innerHTML
      .replaceAll("NEW_RECORD", uniqueId)
      .replaceAll("__BLOCK_KIND__", kind)

    const wrap = document.createElement("div")
    wrap.innerHTML = html.trim()
    const node = wrap.firstElementChild

    const kindSelect = node.querySelector('[name*="[kind]"]')
    if (kindSelect) kindSelect.value = kind

    const heading = node.querySelector('[name*="[heading]"]')
    if (heading && !heading.value) heading.value = `${this.titleize(kind)} Module`

    node.dataset.moduleKind = kind
    const kindLabel = node.querySelector(".rc-module-kind")
    if (kindLabel) kindLabel.textContent = this.titleize(kind)

    this.setLayoutInputs(node, row, slot, cols)
    return node
  }

  refreshRow(row) {
    if (!row) return

    const columns = row.querySelectorAll(".rc-column-list")
    columns.forEach((columnList) => {
      if (columnList.dataset.sortableReady === "true") return
      const sortable = Sortable.create(columnList, {
        group: "rc-modules",
        animation: 150,
        handle: ".rc-module-drag",
        onEnd: () => this.syncLayoutFields()
      })
      this.sortables.push(sortable)
      columnList.dataset.sortableReady = "true"
    })
  }

  syncLayoutFields() {
    const rows = Array.from(this.boardTarget.querySelectorAll(".rc-row"))

    let position = 1
    rows.forEach((rowNode, rowIndex) => {
      const rowNumber = rowIndex + 1
      const columns = Number(rowNode.dataset.columns || 1)
      rowNode.dataset.row = String(rowNumber)
      const header = rowNode.querySelector(".rc-row-header strong")
      if (header) header.textContent = `Row ${rowNumber}`

      rowNode.querySelectorAll(".rc-column").forEach((columnNode, columnIndex) => {
        const slot = columnIndex + 1
        columnNode.dataset.row = String(rowNumber)
        columnNode.dataset.slot = String(slot)
        columnNode.dataset.cols = String(columns)

        columnNode.querySelectorAll(".rc-module").forEach((moduleNode) => {
          this.setLayoutInputs(moduleNode, rowNumber, slot, columns)
          const positionInput = moduleNode.querySelector('input[name*="[position]"]')
          if (positionInput) {
            positionInput.value = position
            position += 1
          }
        })
      })
    })

    if (position === 1) {
      this.renderRow(1, 1)
      this.syncLayoutFields()
    }
  }

  setLayoutInputs(moduleNode, row, slot, cols) {
    const rowInput = moduleNode.querySelector(".rc-row-input")
    const slotInput = moduleNode.querySelector(".rc-col-input")
    const colsInput = moduleNode.querySelector(".rc-cols-input")

    if (rowInput) rowInput.value = row
    if (slotInput) slotInput.value = slot
    if (colsInput) colsInput.value = cols
  }

  visibleModules() {
    return Array.from(this.listTarget.querySelectorAll(".rc-module")).filter((node) => {
      const destroyInput = node.querySelector('input[name*="[_destroy]"]')
      return !destroyInput || destroyInput.value !== "1"
    })
  }

  destroySortables() {
    this.sortables.forEach((sortable) => sortable.destroy())
    this.sortables = []
  }

  nextRowNumber() {
    return this.boardTarget.querySelectorAll(".rc-row").length + 1
  }

  titleize(value) {
    return value.toString().replace(/_/g, " ").replace(/\b\w/g, (ch) => ch.toUpperCase())
  }
}
