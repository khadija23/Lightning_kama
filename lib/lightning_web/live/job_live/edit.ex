defmodule LightningWeb.JobLive.Edit do
  @moduledoc """
  LiveView for editing a single job, which inturn uses `LightningWeb.JobLive.JobFormComponent`
  for common functionality.
  """
  use LightningWeb, :live_view

  alias Lightning.Jobs

  on_mount {LightningWeb.Hooks, :project_scope}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:active_menu_item, :jobs)
     |> assign(:job, Jobs.get_job!(id))}
  end

  defp page_title(:edit), do: "Edit Job"
end
