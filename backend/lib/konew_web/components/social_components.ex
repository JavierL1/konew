defmodule KonewWeb.SocialComponents do
  use KonewWeb, :html

  attr :id, :string, default: "social-component"
  attr :hook, :string, default: nil
  attr :members, :list, default: []
  attr :rest, :global

  def member_list(assigns) do
    ~H"""
    <div id={@id} hook={@hook} {@rest}>
      <h3 class="text-sm font-medium text-zinc-500 dark:text-zinc-400 uppercase tracking-wider mb-4">
        Members Online
      </h3>
      <ul class="space-y-3">
        <%= for member <- @members do %>
          <li class="flex items-center gap-3">
            <div class="h-8 w-8 rounded-full bg-indigo-500 flex items-center justify-center text-white text-xs font-bold">
              {String.at(member.email, 0) |> String.upcase()}
            </div>
            <span class="text-sm text-zinc-700 dark:text-zinc-300 truncate">
              {member.email}
            </span>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
