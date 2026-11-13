import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// The library's file sheet (runeui's drawer, on this controller's element): a tile loads the file
// into the drawer's frame, and this opens the drawer over the page, the address saying which file
// (?asset=) so a refresh or a shared link opens it again. Once it has closed (✕, Esc, a press
// outside), the frame empties and the address forgets the file; if its details were saved, the
// library redraws so the tile shows them. The drawer's events don't bubble: they're listened for
// on the drawer itself (data-action on this element).
export default class extends Controller {
  loaded(event) {
    if (event.target.id !== "media_sheet") return

    const sheet = event.target.querySelector("[data-media-asset-id]")
    if (!sheet) return

    if (!this.element.open) this.element.open = true
    this.changed ||= sheet.hasAttribute("data-media-sheet-changed")
    this.#setAsset(sheet.dataset.mediaAssetId)
  }

  settled(event) {
    if (event.target !== this.element || event.detail?.value !== false) return

    const frame = this.element.querySelector("turbo-frame#media_sheet")
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
