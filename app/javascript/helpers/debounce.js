// Debounces a function by delaying its execution until a certain amount of time has passed
// since the last time it was invoked. Only the last invocation within the delay period will be executed.
export function debounce(fn, delay = 1000) {
  let timeoutId = null

  return (...args) => {
    clearTimeout(timeoutId)
    timeoutId = setTimeout(() => fn.apply(this, args), delay)
  }
}
