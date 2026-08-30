import { Controller } from "@hotwired/stimulus"

const QUESTIONS = [
  { text: "The sky is blue.", answer: true },
  { text: "Fish can breathe air out of water.", answer: false },
  { text: "The earth orbits the sun.", answer: true }
]

export default class extends Controller {
  static targets = ["root"]
  static values = { startUrl: String, finishUrl: String }

  connect() {
    this.token = new URLSearchParams(window.location.search).get("token")
    this.questionIndex = 0
    this.correctCount = 0
    this.started = false
    this.renderQuestion()
  }

  renderQuestion() {
    const question = QUESTIONS[this.questionIndex]
    this.rootTarget.innerHTML = `
      <p class="text-2xl p-8 border-2">${question.text}</p>
      <div class="mt-4 space-x-4">
        <button type="button" data-answer="true" class="bg-green-800 text-white px-4 py-2 rounded">True</button>
        <button type="button" data-answer="false" class="bg-red-800 text-white px-4 py-2 rounded">False</button>
      </div>
    `
    this.rootTarget.querySelectorAll("button").forEach((button) => {
      button.addEventListener("click", () => this.answer(button.dataset.answer === "true"))
    })
  }

  async answer(value) {
    if (!this.started) {
      this.started = true
      await this.post(this.startUrlValue)
    }

    if (value === QUESTIONS[this.questionIndex].answer) this.correctCount += 1

    this.questionIndex += 1
    if (this.questionIndex < QUESTIONS.length) {
      this.renderQuestion()
    } else {
      await this.finish()
    }
  }

  async finish() {
    const outcome = this.correctCount === QUESTIONS.length ? "pass" : "fail"

    await this.post(this.finishUrlValue, {
      game_attempt: { outcome, score: this.correctCount }
    })

    this.rootTarget.innerHTML = `<p>You scored ${this.correctCount} out of ${QUESTIONS.length}.</p>`
  }

  async post(url, extraParams = {}) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content

    await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({ token: this.token, ...extraParams })
    })
  }
}
