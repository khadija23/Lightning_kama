defmodule Lightning.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lightning.Projects` context.
  """

  @doc """
  Generate a project.
  """
  alias Lightning.{JobsFixtures, WorkflowsFixtures, CredentialsFixtures}
  @spec project_fixture(attrs :: Keyword.t()) :: Lightning.Projects.Project.t()
  def project_fixture(attrs \\ []) when is_list(attrs) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        name: "a-test-project",
        project_users: []
      })
      |> Lightning.Projects.create_project()

    project
  end

  @spec full_project_fixture(attrs :: Keyword.t()) :: %{optional(any) => any}
  def full_project_fixture(attrs \\ []) when is_list(attrs) do
    project = project_fixture()

    w1 =
      WorkflowsFixtures.workflow_fixture(
        project_id: project.id,
        name: "workflow 1"
      )

    w2 =
      WorkflowsFixtures.workflow_fixture(
        project_id: project.id,
        name: "workflow 2"
      )

    project_credential =
      CredentialsFixtures.project_credential_fixture(
        name: "new credential",
        body: %{"foo" => "manchu"}
      )

    w1_job =
      JobsFixtures.job_fixture(
        name: "webhook job",
        project_id: project.id,
        workflow_id: w1.id,
        project_credential_id: project_credential.id,
        trigger: %{type: :webhook},
        body: "console.log('webhook job')\nfn(state => state)"
      )

    JobsFixtures.job_fixture(
      name: "on fail",
      project_id: project.id,
      workflow_id: w1.id,
      trigger: %{type: :on_job_failure, upstream_job_id: w1_job.id},
      body: "console.log('on fail')\nfn(state => state)"
    )

    JobsFixtures.job_fixture(
      name: "on success",
      project_id: project.id,
      workflow_id: w1.id,
      trigger: %{type: :on_job_success, upstream_job_id: w1_job.id}
    )

    w2_job =
      JobsFixtures.job_fixture(
        name: "other workflow",
        project_id: project.id,
        workflow_id: w2.id,
        trigger: %{type: :webhook}
      )

    JobsFixtures.job_fixture(
      name: "on fail",
      project_id: project.id,
      workflow_id: w2.id,
      trigger: %{type: :on_job_failure, upstream_job_id: w2_job.id}
    )

    JobsFixtures.job_fixture(
      name: "unrelated job",
      trigger: %{type: :webhook}
    )

    %{project: project, w1: w1, w2: w2}
  end
end
