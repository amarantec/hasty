defmodule HastyWeb.UserLive.Settings do
  use HastyWeb, :live_view

  on_mount {HastyWeb.UserAuth, :require_sudo_mode}

  alias Hasty.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="text-center">
        <.header>
          Account Settings
          <:subtitle>Manage your account email address and password settings</:subtitle>
        </.header>
      </div>

      <.form for={@email_form} id="email_form" phx-submit="update_email" phx-change="validate_email">
        <.input
          field={@email_form[:email]}
          type="email"
          label="Email"
          autocomplete="username"
          required
        />
        <.button variant="primary" phx-disable-with="Changing...">Change Email</.button>
      </.form>

      <div class="divider" />
      
      <div class="text-center">
        <.header>
          Profile Settings
          <:subtitle>Manage your account name and bio</:subtitle>
        </.header>
      </div>
      <.form for={%{}} id="avatar_form" phx-submit="save_avatar">
        <div class="flex flex-col items-center space-y-4">
          <%= if @current_scope.user.profile_image do %>
            <img src={@current_scope.user.profile_image}
              class="rounded-full w-32 h-32 object-cover border" />
          <% else %>
            <div class="rounded-full w-32 h-32 bg-gray-200 flex items-center justify-center">
              <span class="text-gray-500">No Image</span>
            </div>
          <% end %>

          <.live_file_input upload={@uploads.avatar} />

          <%= for entry <- @uploads.avatar.entries do %>
            <article class="upload-entry">
              <span><%= entry.client_name %> (<%= entry.progress %>%)</span>
              <progress value={entry.progress} max="100"></progress>

              <%= for err <- upload_errors(@uploads.avatar, entry) do %>
                <p class="alert alert-danger"><%= error_to_string(err) %></p>
              <% end %>
            </article>
          <% end %>

          <%= for err <- upload_errors(@uploads.avatar) do %>
            <p class="alert alert-danger"><%= error_to_string(err) %></p>
          <% end %>
          <.button
            type="submit"
            variant="primary"
            phx-disable-with="Saving..."
          >
            Save Profile Image
          </.button>
        </div>
      </.form>

      <.form
        for={@user_info_form}
        id="user_info_form"
        phx-submit="update_user_info"
        phx-change="validate_user_info"
      >
        <.input
          field={@user_info_form[:first_name]}
          type="text"
          label="First Name"
        />
        <.input
          field={@user_info_form[:last_name]}
          type="text"
          label="Last Name"
        />
        <.input
          field={@user_info_form[:bio]}
          type="textarea"
          label="Bio"
        />
        <.button variant="primary" phx-disable-with="Saving...">
          Save User Profile
        </.button>
      </.form>

      <div class="divider" />

      <div class="text-center">
        <.button variant="primary" navigate={~p"/contacts"}>Contacts</.button>
        <.button variant="primary" navigate={~p"/addresses"}>Addresses</.button>
      </div>

      <div class="divider" />

      <.form
        for={@password_form}
        id="password_form"
        action={~p"/users/update-password"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
      >
        <input
          name={@password_form[:email].name}
          type="hidden"
          id="hidden_user_email"
          autocomplete="username"
          value={@current_email}
        />
        <.input
          field={@password_form[:password]}
          type="password"
          label="New password"
          autocomplete="new-password"
          required
        />
        <.input
          field={@password_form[:password_confirmation]}
          type="password"
          label="Confirm new password"
          autocomplete="new-password"
        />
        <.button variant="primary" phx-disable-with="Saving...">
          Save Password
        </.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, "Email changed successfully.")

        {:error, _} ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    user_changeset = Accounts.change_user_info(user, %{})

    socket =
      socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:avatar,
        accept: :any,
        max_entries: 1,
        max_file_size: 5_000_000)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(Accounts.change_user_password(user, %{}, hash_password: :false)))
      |> assign(:user_info_form, to_form(user_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_user_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end

  ## User info
  def handle_event("validate_user_info", %{"user" => user_params}, socket) do
    user_info_form =
      Accounts.change_user_info(socket.assigns.current_scope.user, user_params)
      |> Map.put(:action, :validate)
      |> to_form()
    {:noreply, assign(socket, user_info_form: user_info_form)}
  end

  def handle_event("update_user_info", %{"user" => user_params}, socket) do
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)
    case Accounts.update_user_info(user, user_params) do
      {:ok, user} ->
        {:noreply,
        socket
        |> put_flash(:info, "Profile updated successfully.")
        |> assign(:user_info_form, to_form(Accounts.change_user_info(user, %{})))}

    {:error, changeset} ->
      {:noreply, assign(socket, user_info_form: to_form(changeset, action: :insert))}
    end
  end

  def handle_event("save_avatar", _params, socket) do
    user = socket.assigns.current_scope.user

    IO.inspect(socket.assigns.uploads.avatar.entries, label: "Entradas de uploads")

    uploaded_file =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
        filename = "#{user.id}#{Path.extname(entry.client_name)}"
        uploads_dir = Path.join(Application.app_dir(:hasty, "priv/static"), "uploads/profiles")
        dest = Path.join(uploads_dir, filename)

        File.mkdir_p!(uploads_dir)
        File.cp!(path, dest)

        {:ok, "/uploads/profiles/#{filename}"}
        end)
        |> List.first()
      IO.inspect(uploaded_file)

    if uploaded_file do
      {:ok, updated_user} = Accounts.update_profile_image(user, uploaded_file)
      {:noreply,
        socket
        |> put_flash(:info, "Profile image updated.")
        |> assign(:current_scope, %{socket.assigns.current_scope | user: updated_user})}
    else
      {:noreply, put_flash(socket, :error, "Upload failed.")}
    end
  end

  defp error_to_string(:too_large), do: "File is too large"
  defp error_to_string(:too_many_files), do: "To many files"
  defp error_to_string(:not_accepted), do: "Invalid file typr"
  defp error_to_string(_), do: "Upload error"
end
