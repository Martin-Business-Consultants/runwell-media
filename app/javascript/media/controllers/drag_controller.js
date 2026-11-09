import { Controller } from "@hotwired/stimulus"

// A file's tile, picked up to drop on a folder (media--drop): it carries the file's document id and,
// as a type a folder can read while the file is over it, whose library it's in, since a file moves
// only within its own library. The folders of that library show as places to drop while it's dragged.
export default class extends Controller {
  static values = { id: Number, client: Number }

  start(event) {
    event.dataTransfer.setData("application/x-runwell-media", String(this.idValue))
    event.dataTransfer.setData(`application/x-runwell-media-client-${this.clientValue}`, "")
    event.dataTransfer.effectAllowed = "move"
    this.element.classList.add("media-file--dragging")
    document.documentElement.classList.add("media-dragging")
    for (const target of this.targets) target.classList.add("media-drop--target")
  }

  end() {
    this.element.classList.remove("media-file--dragging")
    document.documentElement.classList.remove("media-dragging")
    for (const target of document.querySelectorAll(".media-drop--target")) target.classList.remove("media-drop--target")
  }

  get targets() {
    return document.querySelectorAll(`[data-media--drop-client-value="${this.clientValue}"]`)
  }
}
