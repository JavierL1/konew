defmodule KonewWeb.WhiteboardComponents do
  use KonewWeb, :html

  attr :id, :string, default: "canvas-workspace-root"
  attr :hook, :string, default: nil
  attr :submit_label, :string, default: "Post Drawing"

  @doc """
  Renders the universal application whiteboard markup skeleton surface.
  """
  def whiteboard(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook={@hook}
      class="mx-auto max-w-sm bg-white dark:bg-zinc-950 p-6 rounded-2xl border border-zinc-200 dark:border-zinc-800 shadow-md"
      phx-update="ignore"
    >
      <h1 class="text-xl font-bold mb-4 text-center text-zinc-900 dark:text-white">Create Drawing</h1>

      <%!-- The Canvas Container --%>
      <div class="relative bg-white border border-zinc-300 dark:border-zinc-700 rounded-lg overflow-hidden touch-none">
        <canvas
          id="drawing-canvas"
          width="400"
          height="400"
          class="w-full h-auto cursor-crosshair bg-white"
        >
        </canvas>
      </div>

      <%!-- Toolbar --%>
      <div class="mt-4 flex items-center justify-between gap-2">
        <div class="flex gap-1.5">
          <button
            id="pen-tool"
            type="button"
            class="px-3 py-1.5 bg-zinc-800 text-white rounded-md text-xs font-bold active:scale-95"
          >
            Pen
          </button>
          <button
            id="eraser-tool"
            type="button"
            class="px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600 active:scale-95"
          >
            Eraser
          </button>
        </div>
        <div class="flex gap-1.5">
          <button
            id="undo-tool"
            type="button"
            class="px-3 py-1.5 bg-zinc-200 text-zinc-800 dark:bg-zinc-800 dark:text-zinc-200 rounded-md text-xs border border-zinc-300 dark:border-zinc-600 active:scale-95 transition-all"
          >
            Undo
          </button>
          <button
            id="clear-canvas"
            type="button"
            class="px-3 py-1.5 bg-zinc-200 text-red-800 dark:bg-zinc-800 dark:text-red-400 rounded-md text-xs border border-zinc-300 dark:border-zinc-600 active:scale-95 transition-all"
          >
            Clear
          </button>
        </div>
      </div>

      <%!-- Submit Button --%>
      <button
        id="post-drawing"
        type="button"
        class="w-full mt-6 bg-indigo-600 text-white py-2.5 rounded-xl font-bold hover:bg-indigo-700 transition-colors shadow active:scale-95 text-sm"
      >
        {@submit_label}
      </button>
    </div>
    """
  end
end
