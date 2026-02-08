defmodule MoonWeb.InboxLive.Index do
  use MoonWeb, :live_view

  @folders [
    %{key: "inbox", label: "Inbox", icon: "hero-inbox"},
    %{key: "starred", label: "Starred", icon: "hero-star"},
    %{key: "important", label: "Important", icon: "hero-exclamation-circle"},
    %{key: "sent", label: "Sent", icon: "hero-paper-airplane"},
    %{key: "drafts", label: "Drafts", icon: "hero-document-text"},
    %{key: "spam", label: "Spam", icon: "hero-shield-exclamation"},
    %{key: "trash", label: "Trash", icon: "hero-trash"},
    %{key: "all", label: "All Emails", icon: "hero-envelope"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    emails = generate_dummy_emails()

    {:ok,
     socket
     |> assign(:page_title, "Inbox")
     |> assign(:all_emails, emails)
     |> assign(:active_folder, "inbox")
     |> assign(:status_filter, "all")
     |> assign(:tag_filter, "all")
     |> assign(:search_query, "")
     |> assign(:folders, @folders)
     |> assign(:inbox_count, length(Enum.filter(emails, &(!&1.read))))
     |> stream(:emails, emails)}
  end

  @impl true
  def handle_event("filter", params, socket) do
    search = params["search"] || socket.assigns.search_query
    status = params["status"] || socket.assigns.status_filter
    tag = params["tag"] || socket.assigns.tag_filter

    filtered = apply_filters(socket.assigns.all_emails, status, tag, search)

    {:noreply,
     socket
     |> assign(:search_query, search)
     |> assign(:status_filter, status)
     |> assign(:tag_filter, tag)
     |> stream(:emails, filtered, reset: true)}
  end

  @impl true
  def handle_event("select_folder", %{"folder" => folder}, socket) do
    {:noreply, assign(socket, :active_folder, folder)}
  end

  @impl true
  def handle_event("toggle_star", %{"id" => id}, socket) do
    id = String.to_integer(id)

    all_emails =
      Enum.map(socket.assigns.all_emails, fn
        %{id: ^id} = email -> %{email | starred: !email.starred}
        email -> email
      end)

    filtered =
      apply_filters(
        all_emails,
        socket.assigns.status_filter,
        socket.assigns.tag_filter,
        socket.assigns.search_query
      )

    {:noreply,
     socket
     |> assign(:all_emails, all_emails)
     |> stream(:emails, filtered, reset: true)}
  end

  # -- Filtering helpers --

  defp apply_filters(emails, status_filter, tag_filter, search_query) do
    emails
    |> filter_by_status(status_filter)
    |> filter_by_tag(tag_filter)
    |> filter_by_search(search_query)
  end

  defp filter_by_status(emails, "all"), do: emails
  defp filter_by_status(emails, status), do: Enum.filter(emails, &(&1.status == status))

  defp filter_by_tag(emails, "all"), do: emails
  defp filter_by_tag(emails, tag), do: Enum.filter(emails, &(tag in &1.tags))

  defp filter_by_search(emails, ""), do: emails
  defp filter_by_search(emails, nil), do: emails

  defp filter_by_search(emails, query) do
    q = String.downcase(query)

    Enum.filter(emails, fn email ->
      String.contains?(String.downcase(email.subject), q) ||
        String.contains?(String.downcase(email.from), q) ||
        String.contains?(String.downcase(email.body_preview), q)
    end)
  end

  # -- Template helpers --

  def status_label("waiting_on_us"), do: "Waiting on Us"
  def status_label("waiting_on_customer"), do: "Waiting on Customer"
  def status_label("open"), do: "Open"
  def status_label(_), do: ""

  def status_classes("waiting_on_us"),
    do: "bg-amber-100 text-amber-800 dark:bg-amber-900/30 dark:text-amber-300"

  def status_classes("waiting_on_customer"),
    do: "bg-blue-100 text-blue-800 dark:bg-blue-900/30 dark:text-blue-300"

  def status_classes("open"),
    do: "bg-emerald-100 text-emerald-800 dark:bg-emerald-900/30 dark:text-emerald-300"

  def status_classes(_), do: ""

  def tag_label("tender"), do: "Tender"
  def tag_label("rate"), do: "Rate"
  def tag_label("load"), do: "Load"
  def tag_label("empty_return"), do: "Empty Return"
  def tag_label("quote"), do: "Quote"
  def tag_label(other), do: String.capitalize(other)

  def tag_classes("tender"),
    do: "bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300"

  def tag_classes("rate"),
    do: "bg-lime-100 text-lime-700 dark:bg-lime-900/30 dark:text-lime-300"

  def tag_classes("load"),
    do: "bg-sky-100 text-sky-700 dark:bg-sky-900/30 dark:text-sky-300"

  def tag_classes("empty_return"),
    do: "bg-rose-100 text-rose-700 dark:bg-rose-900/30 dark:text-rose-300"

  def tag_classes("quote"),
    do: "bg-violet-100 text-violet-700 dark:bg-violet-900/30 dark:text-violet-300"

  def tag_classes(_), do: "bg-base-200 text-base-content"

  def format_date(date) do
    Calendar.strftime(date, "%m/%d")
  end

  # -- Dummy data --

  defp generate_dummy_emails do
    [
      %{
        id: 1,
        from: "Charlie's Dispatch",
        from_email: "charlottedispatch@gmail.com",
        thread_count: 2,
        status: "waiting_on_us",
        subject: "Delivery Order FANU3659913",
        body_preview:
          "Dear CHARLIE'S TIRES We have received your order and are processing the delivery for container FANU3659913...",
        tags: ["tender", "rate"],
        date: ~D[2025-12-01],
        starred: false,
        read: false,
        has_attachment: false,
        priority: :high
      },
      %{
        id: 2,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 2,
        status: "waiting_on_customer",
        subject: "Delivery Order TEMU1282305",
        body_preview:
          "Dear WALMART, Your order has been received for Container #TEMU1282305. Please confirm delivery window...",
        tags: ["tender", "rate"],
        date: ~D[2025-11-13],
        starred: false,
        read: false,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 3,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 2,
        status: "waiting_on_customer",
        subject: "Delivery Order TGBU3752218",
        body_preview:
          "Dear WALMART, Your order has been received for Container #TGBU3752218. Estimated arrival at port...",
        tags: ["tender", "load"],
        date: ~D[2025-10-29],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 4,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 1,
        status: "open",
        subject: "RATE QUOTE NEEDED",
        body_preview:
          "Dear Carrier, Please advise best rate for: PICK UP: NJ/NY Ports Destinations: Chicago, IL. 40' container...",
        tags: ["quote"],
        date: ~D[2025-09-11],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 5,
        from: "Charlesdispatch",
        from_email: "charlesdispatch@gmail.com",
        thread_count: 1,
        status: "open",
        subject: "ABC12345",
        body_preview:
          "Dear NJ DIRECT CUSTOMER, Your Delivery / Work order has been received for Container #ABC12345...",
        tags: [],
        date: ~D[2025-08-26],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 6,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 1,
        status: "open",
        subject: "Delivery Order",
        body_preview:
          "Dear Carrier, Please see attached DO. 5 containers Customer: NJ Direct 6 Port: APM Elizabeth...",
        tags: ["tender"],
        date: ~D[2025-08-25],
        starred: false,
        read: true,
        has_attachment: true,
        priority: :normal
      },
      %{
        id: 7,
        from: "Charlesdispatch",
        from_email: "charlesdispatch@gmail.com",
        thread_count: 1,
        status: "open",
        subject: "(No Subject)",
        body_preview:
          "Dear CAROMATIC, HUFFY CORP, Your Delivery / Work order has been received for Container #HUF90234...",
        tags: [],
        date: ~D[2025-08-06],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 8,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 3,
        status: "waiting_on_us",
        subject: "Delivery Order 5 Containers - APM - Elizabeth",
        body_preview:
          "Dear DECKERS BRANDS, We have received your order for 5 containers at APM Elizabeth terminal...",
        tags: ["tender", "rate"],
        date: ~D[2025-07-31],
        starred: false,
        read: false,
        has_attachment: true,
        priority: :normal
      },
      %{
        id: 9,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 1,
        status: "waiting_on_customer",
        subject: "DELIVER ORDER",
        body_preview:
          "Dear WALMART, Your order has been received for Reference #DLV-2025-0724. Please confirm acceptance...",
        tags: ["tender", "load"],
        date: ~D[2025-07-24],
        starred: true,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 10,
        from: "Charlesdispatch",
        from_email: "charlesdispatch@gmail.com",
        thread_count: 1,
        status: "open",
        subject: "(No Subject)",
        body_preview:
          "Dear CAROMATIC, Your Delivery / Work order has been received for Container #CRO77812...",
        tags: ["load"],
        date: ~D[2025-07-15],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 11,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 1,
        status: "open",
        subject: "Quote Request",
        body_preview:
          "Dear Carrier, Please advise best rate for the below: Pick up: NY/NJ Ports Delivery: Midwest...",
        tags: ["quote"],
        date: ~D[2025-07-10],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 12,
        from: "Charlotte Dominguez",
        from_email: "charlotte@portpro.io",
        thread_count: 1,
        status: "open",
        subject: "(No Subject)",
        body_preview:
          "Dear CAROMATIC, Your Delivery / Work order has been received for Container #CAR55109...",
        tags: ["load"],
        date: ~D[2025-06-03],
        starred: false,
        read: true,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 13,
        from: "Charlotte@portpro.io",
        from_email: "charlotte@portpro.io",
        thread_count: 5,
        status: "waiting_on_us",
        subject: "EMPTY LIST 6/2",
        body_preview:
          "Acknowledgement of Empty Return for Container #: FSAU7009. Please confirm pickup schedule...",
        tags: ["empty_return"],
        date: ~D[2025-06-02],
        starred: false,
        read: false,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 14,
        from: "Charlotte@portpro.io",
        from_email: "charlotte@portpro.io",
        thread_count: 2,
        status: "waiting_on_us",
        subject: "EMPTY NOTICE UPDATED 5/29 - CHICAGO",
        body_preview:
          "Acknowledgement of Empty Return for Container #CHI-2025-0529. Updated return location...",
        tags: ["empty_return"],
        date: ~D[2025-05-29],
        starred: false,
        read: false,
        has_attachment: false,
        priority: :normal
      },
      %{
        id: 15,
        from: "Mike Thompson",
        from_email: "mike@abclogistics.com",
        thread_count: 1,
        status: "waiting_on_customer",
        subject: "Re: Rate Confirmation - LAX to ORD",
        body_preview:
          "Hi team, We've reviewed the rate confirmation for the LAX to ORD lane. Please confirm the agreed rate...",
        tags: ["rate"],
        date: ~D[2025-05-15],
        starred: true,
        read: true,
        has_attachment: true,
        priority: :normal
      },
      %{
        id: 16,
        from: "Sarah Chen",
        from_email: "sarah@globalfreight.com",
        thread_count: 4,
        status: "waiting_on_us",
        subject: "Urgent: Container Availability - Port Newark",
        body_preview:
          "Dear Operations, We have an urgent need for 3x40' containers at Port Newark by end of week...",
        tags: ["tender", "load"],
        date: ~D[2025-05-10],
        starred: false,
        read: false,
        has_attachment: false,
        priority: :high
      }
    ]
  end
end
