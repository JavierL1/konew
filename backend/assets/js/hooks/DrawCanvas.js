import { DrawingBoard } from "../drawing_board"

export const DrawCanvas = {
    mounted() {
        const canvas = this.el.querySelector('#drawing-canvas')
        this.board = new DrawingBoard(canvas)

        const penBtn = this.el.querySelector('#pen-tool')
        const eraserBtn = this.el.querySelector('#eraser-tool')
        const undoBtn = this.el.querySelector('#undo-tool')
        const clearBtn = this.el.querySelector('#clear-canvas')
        const postBtn = this.el.querySelector('#post-drawing')

        penBtn.onclick = () => {
            this.board.setPen()
            penBtn.className = "px-3 py-1.5 bg-zinc-800 text-white rounded-md text-xs font-bold shadow-inner"
            eraserBtn.className = "px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600"
        }

        eraserBtn.onclick = () => {
            this.board.setEraser()
            eraserBtn.className = "px-3 py-1.5 bg-zinc-800 text-white rounded-md text-xs font-bold shadow-inner"
            penBtn.className = "px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600"
        }

        clearBtn.onclick = () => this.board.clear()
        undoBtn.onclick = () => this.board.undo()

        postBtn.onclick = () => {
            this.pushEvent("submit-drawing", {
                "image-data": this.board.getDataUri(),
                strokes: this.board.getStrokes()
            })
        }
    }
}
