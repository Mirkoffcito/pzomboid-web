defmodule TfzWeb.ZomboidLayouts do
  use TfzWeb, :html

  attr :active, :atom, default: :online

  def navbar(assigns) do
    ~H"""
    <header class="matrix-nav">
      <div class="mx-auto max-w-4xl px-4 sm:px-6 h-16 flex items-center justify-between">
        <!-- Brand -->
        <div class="flex items-center gap-3 min-w-0">
          <.link href={~p"/zomboid"} class="matrix-brand truncate">
            TFZ Zomboid
          </.link>
          <span class="matrix-nav-sub hidden sm:inline truncate">Player Tracker</span>
        </div>

        <!-- Desktop links -->
        <nav class="matrix-nav-links hidden sm:inline-flex" aria-label="Zomboid navigation">
          <.link href={~p"/zomboid"} class={matrix_nav_item(@active, :online)}>
            En línea
          </.link>
          <.link href={~p"/zomboid/players"} class={matrix_nav_item(@active, :players)}>
            Jugadores
          </.link>
        </nav>

        <!-- Mobile menu -->
        <div class="dropdown dropdown-end sm:hidden">
          <label tabindex="0" class="btn btn-ghost btn-sm matrix-nav-icon" aria-label="Abrir menú">
            <!-- simple hamburger icon -->
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none"
                viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
              <path stroke-linecap="round" stroke-linejoin="round"
                    d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </label>

          <ul tabindex="0" class="menu dropdown-content mt-3 w-52 rounded-box matrix-nav-menu">
            <li>
              <.link href={~p"/zomboid"} class={matrix_nav_menu_item(@active, :online)}>
                <span class="matrix-dot" data-active={@active == :online}></span>
                En línea
              </.link>
            </li>
            <li>
              <.link href={~p"/zomboid/players"} class={matrix_nav_menu_item(@active, :players)}>
                <span class="matrix-dot" data-active={@active == :players}></span>
                Jugadores
              </.link>
            </li>
          </ul>
        </div>
      </div>
    </header>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="matrix-footer">
      <div class="mx-auto max-w-4xl px-6 py-4 text-center text-sm">
        © <%= Date.utc_today().year %> <span class="font-semibold">Guido Medina</span>
        — TFZ Zomboid Tracker
      </div>
    </footer>
    """
  end

  defp matrix_nav_item(active, key) do
    base = "matrix-nav-item"
    if active == key, do: base <> " is-active", else: base
  end

  defp matrix_nav_menu_item(active, key) do
    base = "matrix-nav-menu-item"
    if active == key, do: base <> " is-active", else: base
  end
end
