// app/javascript/controllers/upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label"]

  updateLabel(event) {
    const fileName = event.target.files[0]?.name
    if (fileName) {
      this.labelTarget.innerHTML = `<span class="text-zinc-200">${fileName}</span>`
      this.labelTarget.classList.add("text-zinc-200")
    }
  }
}