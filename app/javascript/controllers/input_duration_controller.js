import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="input-duration"
export default class extends Controller {
  static targets = ["input", "icon"]

  // order
  // 'input' event is triggered whenever the value of the input changes.
  // •	Fires after the input’s value has changed.

  // 'keydown' event is triggered when a key is pressed down on the keyboard while the input is focused.
  // 	•	Fires before the input’s value has changed.
  // •	You can detect which key is being pressed using event.key or event.code.

// 

  connect() {
    // this.inputTarget.addEventListener('input', this.sanitizeInput.bind(this))
    this.inputTarget.addEventListener('click', this.handleClick.bind(this))
    this.inputTarget.addEventListener('keydown', this.handleKeydown.bind(this))
    this.inputTarget.addEventListener('focus', this.handleFocus.bind(this))
  }

  // 'keydown' event is triggered when a key is pressed down on the keyboard while the input is focused.
  // 	•	Fires before the input’s value has changed.
  // •	You can detect which key is being pressed using event.key or event.code.

  
  handleClick(event) {
    event.preventDefault()
    
    const isCaretAtHours = this.inputTarget.selectionStart <= 2
    
    if (isCaretAtHours) {
      this.#moveCaretToHours()
    } else {
      this.#moveCaretToMinutes()
    }
  }
  
  handleFocus(event) {
    event.preventDefault()
    this.#moveCaretToHours()
  }

  handleKeydown(event) {
    const isNavigationKey = ['ArrowUp', 'ArrowDown', 'ArrowRight', 'ArrowLeft', 'Tab', 'Backspace'].includes(event.key)
    const isNumericKey = event.key >= '0' && event.key <= '9'

    if (!isNavigationKey && !isNumericKey) {
      event.preventDefault()

      return 
    }
    
    
    if (isNavigationKey) {
      this.handleNavigationKey(event)
      return
    }
    
    if (isNumericKey) {
      this.handleNumericKey(event)
      return
    }
  }

  handleNumericKey(event) {
    event.preventDefault()

    const key = event.key
    const input = this.inputTarget
    const value = input.value || "00:00"
    const [hours, minutes] = value.split(':').map(Number)

    let newHours = isNaN(hours) ? 0 : hours
    let newMinutes = isNaN(minutes) ? 0 : minutes

    const isCaretAtHours = input.selectionStart <= 2

    if (isCaretAtHours) {
      let newHours = Number(String(hours) + String(key))

      if (newHours > 23) {
        newHours = Number(key)
      }

      input.value = this.#buildValue(newHours, newMinutes)
      this.#moveCaretToHours()
    } else {
      newMinutes = Number(String(minutes) + String(key))
      
      if (newMinutes > 59) {
        newMinutes = Number(key)
      }

      input.value = this.#buildValue(newHours, newMinutes)
      this.#moveCaretToMinutes()
    }
  }

  // we didn't change the value yet.
  handleNavigationKey(event) {
    const input = this.inputTarget
    const value = input.value || "00:00"
    const [hours, minutes] = value.split(':').map(Number)

    let newHours = isNaN(hours) ? 0 : hours
    let newMinutes = isNaN(minutes) ? 0 : minutes

    const isCaretAtHours = input.selectionStart <= 2
    const isCaretAtMinutes = input.selectionStart >= 3

    switch (event.key) {
      case "ArrowUp":
        event.preventDefault()

        if (isCaretAtHours) {
          newHours = this.#increaseHours(hours)
        } else {
          newMinutes = this.#increaseMinutes(minutes)
        }

        input.value = this.#buildValue(newHours, newMinutes)
        isCaretAtHours ? this.#moveCaretToHours() : this.#moveCaretToMinutes()
        break

      case "ArrowDown":
        event.preventDefault()

        if (isCaretAtHours) {
          newHours = this.#decreaseHours(hours)
        } else {
          newMinutes = this.#decreaseMinutes(minutes)
        }        

        input.value = this.#buildValue(newHours, newMinutes)
        isCaretAtHours ? this.#moveCaretToHours() : this.#moveCaretToMinutes()
        break

      case "ArrowRight":
        event.preventDefault()

        isCaretAtHours && this.#moveCaretToMinutes()
        break

      case "ArrowLeft":
        event.preventDefault()

        isCaretAtMinutes && this.#moveCaretToHours()
        break
      
      case "Tab":
        if (isCaretAtHours) {
          event.preventDefault()
          this.#moveCaretToMinutes()
        }

        break
      
      case "Backspace":
        event.preventDefault()
        break

      default:
        break
    }
  }

  #moveCaretToHours() {
    this.inputTarget.setSelectionRange(0, 2)
  }

  #moveCaretToMinutes() {
    this.inputTarget.setSelectionRange(3, 5)
  }

  #buildValue(hours, minutes) {
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`
  }

  #increaseHours(hours) {
    if (hours >= 23) {
      return hours
    }
    
    return hours + 1
  }

  #increaseMinutes(minutes) {
    if (minutes >= 59) {
      return 0
    }
    
    return minutes + 1
  }

  #decreaseHours(hours) {
    if (hours <= 0) {
      return 0
    }

    return hours - 1
  }

  #decreaseMinutes(minutes) {
    if (minutes <= 0) {
      return 59
    }

    return minutes - 1  
  }
}
