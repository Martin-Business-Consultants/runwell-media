import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

// A folder (in the sidebar, or a folder's tile) a file can be dropped on: the file moves there
// (Media::Documents::MovesController), and the page redraws in place with a notice. Only a file from
// the same library (client) is taken: the sidebar lists every library's folders.
export default class extends Controller {
  static values = { url: String, folder: String, client: Number }

  over(event) {
    if (!this.accepts(event)) return

    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    this.element.classList.add("media-drop--over")
  }

  leave() {
    this.element.classList.remove("media-drop--over")
  }

  async drop(event) {
    const id = event.dataTransfer.getData("application/x-runwell-media")
    if (!id || !this.accepts(event)) return

    event.preventDefault()
    this.element.classList.remove("media-drop--over")
    document.documentElement.classList.remove("media-dragging")
    for (const target of document.querySelectorAll(".media-drop--target")) target.classList.remove("media-drop--target")
    const body = new FormData()
    body.append("folder_id", this.folderValue)
    await post(this.urlValue.replace("__id__", id), { body, responseKind: "turbo-stream" })
  }

  accepts(event) {
    const types = event.dataTransfer.types
    return types.includes("application/x-runwell-media") && types.includes(`application/x-runwell-media-client-${this.clientValue}`)
  }
}
