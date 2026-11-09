import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// The library's file sheet: a tile loads the file into the sheet's frame, and this opens it over
// the page, the address saying which file (?asset=) so a refresh or a shared link opens it again.
// Closing it (✕, Esc, a click outside) clears the address; if its details were saved, the library
// redraws so the tile shows them.
export default class extends Controller {
  loaded(event) {
    if (event.target.id !== "media_sheet") return

    const sheet = event.target.querySelector("[data-media-asset-id]")
    if (!sheet) return

    if (!this.element.open) this.element.showModal()
    this.changed ||= sheet.hasAttribute("data-media-sheet-changed")
    this.#setAsset(sheet.dataset.mediaAssetId)
  }

  close() {
    this.element.close()
  }

  backdrop(event) {
    if (event.target === this.element) this.close()
  }

  closed() {
    const frame = this.element.querySelector("turbo-frame")
    frame.removeAttribute("src")
    frame.replaceChildren()
    this.#setAsset(null)

    if (this.changed) {
      this.changed = false
      Turbo.visit(window.location.href, { action: "replace" })
    }
  }

  #setAsset(id) {
    const url = new URL(window.location.href)
    id ? url.searchParams.set("asset", id) : url.searchParams.delete("asset")
    window.history.replaceState(window.history.state, "", url)
  }
}
