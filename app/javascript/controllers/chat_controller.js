import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["responses"]

  connect() {
    this.scrollToBottom()
  }

  reset() {
    this.element.querySelector('#query').value = ""
    setTimeout(() => this.scrollToBottom(), 300)
  }

  scrollToBottom() {
    this.responsesTarget.scrollTo({
      top: this.responsesTarget.scrollHeight,
      behavior: "smooth"
    })
  }
}
