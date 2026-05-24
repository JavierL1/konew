// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import { hooks as colocatedHooks } from "phoenix-colocated/konew"
import topbar from "../vendor/topbar"
import { DrawingBoard } from "./drawing_board"
import { DrawCanvas } from "./hooks/DrawCanvas"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: { ...colocatedHooks, DrawCanvas },
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({ detail: reloader }) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if (keyDown === "c") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if (keyDown === "d") {
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

/**
 * Initializes the standalone drawing board on non-LiveView traditional pages.
 * Looks for the container by its standardized structural ID token.
 */
function initStandaloneWhiteboard() {
  const root = document.getElementById("standalone-canvas-root")

  // Guard 1: Abort if the static whiteboard container isn't present on this page
  if (!root) return

  // Guard 2: If LiveView is actively managing this node, step back and let the Hook take over
  if (root.hasAttribute("phx-hook")) return

  const canvas = root.querySelector('#drawing-canvas')
  const board = new DrawingBoard(canvas)

  const penBtn = root.querySelector('#pen-tool')
  const eraserBtn = root.querySelector('#eraser-tool')
  const undoBtn = root.querySelector('#undo-tool')
  const clearBtn = root.querySelector('#clear-canvas')
  const postBtn = root.querySelector('#post-drawing')

  // Toolbar Selection Actions + UI Active Style Toggles
  penBtn.onclick = () => {
    board.setPen()
    penBtn.className = "px-3 py-1.5 bg-zinc-800 text-white rounded-md text-xs font-bold shadow-inner"
    eraserBtn.className = "px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600"
  }

  eraserBtn.onclick = () => {
    board.setEraser()
    eraserBtn.className = "px-3 py-1.5 bg-zinc-800 text-white rounded-md text-xs font-bold shadow-inner"
    penBtn.className = "px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600"
  }

  // Utility Actions
  clearBtn.onclick = () => board.clear()
  undoBtn.onclick = () => board.undo()

  // Background Form Submission (Traditional HTTP REST Pipeline)
  postBtn.onclick = () => {
    canvas.toBlob((blob) => {
      const formData = new FormData()
      formData.append('drawing', blob, 'drawing.png')

      // Extracts the application CSRF token generated inside standard layouts
      const csrfToken = document.querySelector("input[name='_csrf_token']").value
      formData.append('_csrf_token', csrfToken)

      fetch('/drawings', {
        method: 'POST',
        body: formData
      }).then(res => {
        if (res.redirected) {
          window.location.href = res.url
        } else if (res.ok) {
          window.location.href = "/drawings"
        }
      }).catch(err => {
        console.error("Failed to post drawing asset entry:", err)
      })
    }, 'image/png')
  }
}

// Fire on standard initial server-rendered page layout boots
document.addEventListener("DOMContentLoaded", initStandaloneWhiteboard)

// Fire on Phoenix LiveView navigation loops to catch dead-views loaded through live patches
window.addEventListener("phx:page-loading-stop", _info => initStandaloneWhiteboard())
