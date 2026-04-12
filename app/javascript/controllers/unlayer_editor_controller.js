import { Controller } from "@hotwired/stimulus"

const UNLAYER_SCRIPT = "https://editor.unlayer.com/embed.js"

export default class extends Controller {
  static targets = ["canvas", "json", "html"]

  connect() {
    this.editorId = `unlayer-editor-${Date.now()}`
    this.canvasTarget.id = this.editorId
    this.canvasTarget.innerHTML = ""
    this.submitting = false

    this.form = this.element.closest("form")
    this.handleSubmitBound = this.handleSubmit.bind(this)
    this.form?.addEventListener("submit", this.handleSubmitBound)

    this.loadUnlayer()
      .then(() => this.initUnlayer())
      .catch(() => {
        this.canvasTarget.innerHTML = "<p style='color:#b42318'>Unable to load visual builder. Please check your network and reload.</p>"
      })
  }

  disconnect() {
    this.form?.removeEventListener("submit", this.handleSubmitBound)
  }

  async handleSubmit(event) {
    if (!window.unlayer || this.submitting) return

    event.preventDefault()
    this.submitting = true

    await this.exportDesign()
    this.form.submit()
  }

  loadUnlayer() {
    if (window.unlayer) return Promise.resolve()

    return new Promise((resolve, reject) => {
      const existing = document.querySelector(`script[src='${UNLAYER_SCRIPT}']`)
      if (existing) {
        existing.addEventListener("load", resolve, { once: true })
        existing.addEventListener("error", reject, { once: true })
        return
      }

      const script = document.createElement("script")
      script.src = UNLAYER_SCRIPT
      script.async = true
      script.onload = resolve
      script.onerror = reject
      document.head.appendChild(script)
    })
  }

  initUnlayer() {
    window.unlayer.init({
      id: this.editorId,
      displayMode: "web",
      bodyWidth: 1440,
      appearance: {
        theme: "light"
      },
      features: {
        stockImages: true
      },
      tools: {
        html: { enabled: true },
        text: { enabled: true },
        image: { enabled: true },
        button: { enabled: true },
        divider: { enabled: true },
        menu: { enabled: false },
        social: { enabled: false }
      }
    })

    const designJson = this.jsonTarget.value

    window.unlayer.addEventListener("editor:ready", () => {
      if (designJson) {
        try {
          window.unlayer.loadDesign(JSON.parse(designJson))
        } catch {
          // Ignore invalid persisted design payload and continue with blank canvas.
        }
      }

      this.exportDesign()
    })

    window.unlayer.addEventListener("design:updated", () => {
      this.exportDesign()
    })
  }

  exportDesign() {
    return new Promise((resolve) => {
      window.unlayer.exportHtml((data) => {
        this.jsonTarget.value = JSON.stringify(data.design || {})
        this.htmlTarget.value = this.postProcessHtml(data.html || "")
        resolve()
      })
    })
  }

  // Extract body content + head styles from Unlayer's full-document export,
  // then make all pixel-width tables fluid so layouts expand to full page width.
  postProcessHtml(html) {
    if (!html) return ""

    const parser = new DOMParser()
    const doc = parser.parseFromString(html, "text/html")

    // Pull <style> blocks from <head> so they're included without a nested <html>
    const headStyles = Array.from(doc.head.querySelectorAll("style"))
      .map(el => el.outerHTML)
      .join("\n")

    // Make every table that has a fixed pixel width fluid
    doc.body.querySelectorAll("table").forEach(table => {
      const attrW = table.getAttribute("width")
      if (attrW && !attrW.includes("%")) {
        table.setAttribute("width", "100%")
      }
      if (table.style.width && !table.style.width.includes("%") && table.style.width !== "100%") {
        table.style.width = "100%"
      }
      if (table.style.maxWidth && !table.style.maxWidth.includes("%")) {
        table.style.maxWidth = "100%"
      }
    })

    // Make images fill their column cell and stay responsive
    doc.body.querySelectorAll("img").forEach(img => {
      img.removeAttribute("width")
      img.removeAttribute("height")
      img.style.width = "100%"
      img.style.height = "auto"
      img.style.maxWidth = "100%"
      img.style.display = "block"
    })

    return headStyles + "\n" + doc.body.innerHTML
  }
}
