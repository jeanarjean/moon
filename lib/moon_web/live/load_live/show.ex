defmodule MoonWeb.LoadLive.Show do
  use MoonWeb, :live_view

  import MoonWeb.InboxLive.Index,
    only: [
      status_label: 1,
      status_classes: 1,
      tag_label: 1,
      tag_classes: 1,
      format_date: 1,
      generate_dummy_emails: 0
    ]

  @tabs [
    %{key: "load_info", label: "Load Info", icon: "hero-truck"},
    %{key: "billing", label: "Billing", icon: "hero-document-text"},
    %{key: "documents", label: "Documents", icon: "hero-folder"},
    %{key: "payments", label: "Payments & Credits", icon: "hero-credit-card"},
    %{key: "routing", label: "Routing", icon: "hero-arrow-path-rounded-square"},
    %{key: "expenses", label: "Payable & Expenses", icon: "hero-banknotes"},
    %{key: "tracking", label: "Tracking", icon: "hero-map-pin"},
    %{key: "communication", label: "Communication", icon: "hero-chat-bubble-left-right"},
    %{key: "audit", label: "Audit", icon: "hero-clipboard-document-check"},
    %{key: "notes", label: "Notes", icon: "hero-pencil-square"}
  ]

  @impl true
  def mount(%{"reference" => reference}, _session, socket) do
    load = get_load(reference)

    if load do
      associated_emails = get_associated_emails(load.associated_email_ids)

      {:ok,
       socket
       |> assign(:page_title, "Load #: #{load.reference}")
       |> assign(:load, load)
       |> assign(:tabs, @tabs)
       |> assign(:active_tab, "communication")
       |> assign(:comm_sub_tab, "email")
       |> assign(:associated_emails, associated_emails)
       |> stream(:load_emails, associated_emails)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Load not found")
       |> push_navigate(to: ~p"/inbox")}
    end
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  @impl true
  def handle_event("change_comm_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :comm_sub_tab, tab)}
  end

  # -- Helpers --

  def load_status_classes("Pending"),
    do: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300"

  def load_status_classes("In Transit"),
    do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300"

  def load_status_classes("Delivered"),
    do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300"

  def load_status_classes(_), do: "bg-base-200 text-base-content/70"

  defp get_associated_emails(email_ids) do
    all = generate_dummy_emails()
    Enum.filter(all, &(&1.id in email_ids))
  end

  # -- Load data --

  defp get_load(reference) do
    loads = %{
      "B6SV5_NEW_M100117" => %{
        reference: "B6SV5_NEW_M100117",
        status: "Pending",
        customer: %{name: "Walmart", address: "3450 Historic Sully Way, Chantilly, VA 20151, US"},
        pickup: %{name: "APM", address: "5080 McLester Street, Elizabeth, NJ 07207, USA"},
        delivery: %{
          name: "Walmart",
          address: "1872 New Jersey 88, Brick Township, NJ 08724, US"
        },
        return_terminal: %{
          name: "APM",
          address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
        },
        container: "FANU3659913",
        bol: "SHA25088Q8F2",
        chassis: nil,
        ssl: "HAPAG",
        size: "40'",
        created_by: "Matt",
        created_date: "11/24/25 02:32 PM",
        customer_reps: [],
        associated_email_ids: [1]
      },
      "WM_ORD_2_2025" => %{
        reference: "WM_ORD_2_2025",
        status: "Pending",
        customer: %{
          name: "Walmart",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        pickup: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        delivery: %{
          name: "Walmart DC",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        return_terminal: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        container: "TEMU1282305",
        bol: "MHR20251113A",
        chassis: "CHSZ-44821",
        ssl: "MAERSK",
        size: "40'",
        created_by: "Charlotte",
        created_date: "11/13/25 10:00 AM",
        customer_reps: ["CD"],
        associated_email_ids: [2]
      },
      "WM_ORD_3_2025" => %{
        reference: "WM_ORD_3_2025",
        status: "Pending",
        customer: %{
          name: "Walmart",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        pickup: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        delivery: %{
          name: "Walmart DC",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        return_terminal: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        container: "TGBU3752218",
        bol: "MHR20251029B",
        chassis: nil,
        ssl: "MSC",
        size: "40' HC",
        created_by: "Charlotte",
        created_date: "10/29/25 09:15 AM",
        customer_reps: ["CD"],
        associated_email_ids: [3]
      },
      "WM_ORD_9_2025" => %{
        reference: "WM_ORD_9_2025",
        status: "In Transit",
        customer: %{
          name: "Walmart",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        pickup: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        delivery: %{
          name: "Walmart DC",
          address: "300 Enterprise Ave, Pedricktown, NJ 08067, US"
        },
        return_terminal: %{
          name: "Maher Terminal",
          address: "1210 Corbin Street, Elizabeth, NJ 07201, USA"
        },
        container: "DLV-2025-0724",
        bol: "MHR20250724C",
        chassis: "CHSZ-55102",
        ssl: "COSCO",
        size: "40'",
        created_by: "Charlotte",
        created_date: "07/24/25 11:00 AM",
        customer_reps: ["CD"],
        associated_email_ids: [9]
      },
      "DKR_APM_1_2025" => %{
        reference: "DKR_APM_1_2025",
        status: "In Transit",
        customer: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        pickup: %{name: "APM", address: "5080 McLester Street, Elizabeth, NJ 07207, USA"},
        delivery: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        return_terminal: %{
          name: "APM",
          address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
        },
        container: "APMU7700001",
        bol: "APM20250801D",
        chassis: "CHSZ-61234",
        ssl: "ONE",
        size: "40' HC",
        created_by: "Charlotte",
        created_date: "07/31/25 09:00 AM",
        customer_reps: ["CD", "JR"],
        associated_email_ids: [8]
      },
      "DKR_APM_2_2025" => %{
        reference: "DKR_APM_2_2025",
        status: "Pending",
        customer: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        pickup: %{name: "APM", address: "5080 McLester Street, Elizabeth, NJ 07207, USA"},
        delivery: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        return_terminal: %{
          name: "APM",
          address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
        },
        container: "APMU7700002",
        bol: "APM20250801E",
        chassis: nil,
        ssl: "ONE",
        size: "40'",
        created_by: "Charlotte",
        created_date: "07/31/25 09:00 AM",
        customer_reps: ["CD", "JR"],
        associated_email_ids: [8]
      },
      "DKR_APM_3_2025" => %{
        reference: "DKR_APM_3_2025",
        status: "Pending",
        customer: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        pickup: %{name: "APM", address: "5080 McLester Street, Elizabeth, NJ 07207, USA"},
        delivery: %{
          name: "Deckers Brands",
          address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
        },
        return_terminal: %{
          name: "APM",
          address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
        },
        container: "APMU7700003",
        bol: "APM20250801F",
        chassis: nil,
        ssl: "ONE",
        size: "40'",
        created_by: "Charlotte",
        created_date: "07/31/25 09:00 AM",
        customer_reps: ["CD", "JR"],
        associated_email_ids: [8]
      },
      "ER_13_2025" => %{
        reference: "ER_13_2025",
        status: "Pending",
        customer: %{
          name: "Various",
          address: "1200 Port Newark Blvd, Newark, NJ 07114, USA"
        },
        pickup: %{
          name: "Customer Yard",
          address: "1200 Port Newark Blvd, Newark, NJ 07114, USA"
        },
        delivery: %{
          name: "Port Newark Container Terminal",
          address: "241 Calcutta Street, Newark, NJ 07114, USA"
        },
        return_terminal: nil,
        container: "FSAU7009",
        bol: nil,
        chassis: nil,
        ssl: "ZIM",
        size: "40'",
        created_by: "Operations",
        created_date: "06/02/25 08:00 AM",
        customer_reps: [],
        associated_email_ids: [13]
      },
      "ER_14_2025" => %{
        reference: "ER_14_2025",
        status: "Pending",
        customer: %{name: "Various", address: "4200 W 36th Street, Chicago, IL 60632, USA"},
        pickup: %{
          name: "Customer Yard",
          address: "4200 W 36th Street, Chicago, IL 60632, USA"
        },
        delivery: %{
          name: "BNSF Logistics Park",
          address: "26900 S Ridgeland Ave, Elwood, IL 60421, USA"
        },
        return_terminal: nil,
        container: "CHI-2025-0529",
        bol: nil,
        chassis: nil,
        ssl: "EVERGREEN",
        size: "40' HC",
        created_by: "Operations",
        created_date: "05/29/25 10:30 AM",
        customer_reps: [],
        associated_email_ids: [14]
      }
    }

    # Also generate default loads for emails that use the generic pattern
    default_refs =
      for email <- generate_dummy_emails(),
          email.id not in [1, 2, 3, 8, 9, 13, 14],
          into: %{} do
        ref = "REF_#{email.id}_2025"

        {ref,
         %{
           reference: ref,
           status: "Pending",
           customer: %{
             name: String.capitalize(email.from),
             address: "100 Industrial Pkwy, Edison, NJ 08837, US"
           },
           pickup: %{name: "Port Newark", address: "241 Calcutta Street, Newark, NJ 07114, USA"},
           delivery: %{
             name: "Customer Warehouse",
             address: "100 Industrial Pkwy, Edison, NJ 08837, US"
           },
           return_terminal: %{
             name: "Port Newark",
             address: "241 Calcutta Street, Newark, NJ 07114, USA"
           },
           container: String.slice(email.subject, 0, 15),
           bol: nil,
           chassis: nil,
           ssl: "VARIOUS",
           size: "40'",
           created_by: "System",
           created_date: Calendar.strftime(email.date, "%m/%d/%y 12:00 PM"),
           customer_reps: [],
           associated_email_ids: [email.id]
         }}
      end

    Map.merge(loads, default_refs) |> Map.get(reference)
  end
end
