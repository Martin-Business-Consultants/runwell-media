import { Controller } from "@hotwired/stimulus"

// A file's tile in the library, picked up to drop on a folder (media--drop): it carries the file's
// document id, and the page shows the folders as places to drop while it's dragged.
export default class extends Controller {
  static values = { id: Number }

  start(event) {
    event.dataTransfer.setData("application/x-runwell-media", String(this.idValue))
    event.dataTransfer.effectAllowed = "move"
    this.element.classList.add("media-file--dragging")
    document.documentElement.classList.add("media-dragging")
  }

  end() {
    this.element.classList.remove("media-file--dragging")
    document.documentElement.classList.remove("media-dragging")
  }
}
