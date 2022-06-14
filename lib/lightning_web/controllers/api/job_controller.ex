defmodule LightningWeb.API.JobController do
  use LightningWeb, :controller

  alias Lightning.Jobs
  # alias Lightning.Jobs.Job

  action_fallback LightningWeb.FallbackController

  def index(conn, %{"project_id" => project_id} = params) do
    pagination_attrs = Map.take(params, ["page_size", "page"])

    with project <- Lightning.Projects.get_project(project_id),
         :ok <-
           Bodyguard.permit(
             Jobs.Policy,
             :list,
             conn.assigns.current_user,
             project
           ) do
      page =
        Jobs.jobs_for_project_query(project)
        |> Lightning.Repo.paginate(pagination_attrs)

      render(conn, "index.json", page: page, conn: conn)
    end
  end

  def index(conn, params) do
    pagination_attrs = Map.take(params, ["page_size", "page"])

    page =
      Jobs.Query.jobs_for(conn.assigns.current_user)
      |> Lightning.Repo.paginate(pagination_attrs)

    render(conn, "index.json", page: page, conn: conn)
  end

  def show(conn, %{"id" => id}) do
    job = Jobs.get_job!(id)
    render(conn, "show.json", job: job, conn: conn)
  end
end
