import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reservationsList", "toggleButton"]

  toggleReservations(event) {
    const roomId = event.currentTarget.dataset.roomId
    const reservationsList = this.reservationsListTarget
    const button = this.toggleButtonTarget

    if (reservationsList.classList.contains('hidden')) {
      reservationsList.classList.remove('hidden')
      button.textContent = 'Masquer les réservations'
    } else {
      reservationsList.classList.add('hidden')
      button.textContent = 'Voir les réservations'
    }
  }
}
