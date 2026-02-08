defmodule MoonWeb.InboxLive.Show do
  use MoonWeb, :live_view

  import MoonWeb.InboxLive.Index,
    only: [
      status_label: 1,
      status_classes: 1,
      tag_label: 1,
      tag_classes: 1,
      generate_dummy_emails: 0
    ]

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    email_id = String.to_integer(id)
    all_emails = generate_dummy_emails()
    email = Enum.find(all_emails, &(&1.id == email_id))

    if email do
      thread = generate_thread(email)
      load_info = generate_load_info(email)
      all_ids = Enum.map(all_emails, & &1.id)
      idx = Enum.find_index(all_ids, &(&1 == email_id))
      prev_id = if idx > 0, do: Enum.at(all_ids, idx - 1)
      next_id = if idx < length(all_ids) - 1, do: Enum.at(all_ids, idx + 1)

      {:ok,
       socket
       |> assign(:page_title, email.subject)
       |> assign(:email, email)
       |> assign(:thread, thread)
       |> assign(:load_info, load_info)
       |> assign(:participant_count, count_participants(thread))
       |> assign(:prev_id, prev_id)
       |> assign(:next_id, next_id)}
    else
      {:ok,
       socket
       |> put_flash(:error, "Email not found")
       |> push_navigate(to: ~p"/inbox")}
    end
  end

  # -- Helpers --

  def initials(name) do
    name
    |> String.split(~r/[\s'.@]+/)
    |> Enum.filter(&(&1 != ""))
    |> Enum.take(2)
    |> Enum.map(&String.first/1)
    |> Enum.join("")
    |> String.upcase()
  end

  def format_datetime(naive) do
    Calendar.strftime(naive, "%m/%d/%y %I:%M %p")
  end

  def load_status_classes("Pending"),
    do: "bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-300"

  def load_status_classes("In Transit"),
    do: "bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300"

  def load_status_classes("Delivered"),
    do: "bg-emerald-100 text-emerald-700 dark:bg-emerald-900/30 dark:text-emerald-300"

  def load_status_classes(_), do: "bg-base-200 text-base-content/70"

  defp count_participants(thread) do
    thread
    |> Enum.flat_map(fn msg -> [msg.sender_email | msg.recipient_emails] end)
    |> Enum.uniq()
    |> length()
  end

  # -- Thread data generation --

  defp generate_thread(email) do
    case email.id do
      1 -> thread_for_email_1(email)
      _ -> generic_thread(email)
    end
  end

  defp thread_for_email_1(_email) do
    [
      %{
        id: 1,
        sender_name: "Charlotte Dominguez",
        sender_email: "charlotte@metalogisticsservices.com",
        sender_initials: "CD",
        recipients: "to: me, adminoutermoon and 2 more",
        recipient_emails: ["me@demo.com", "adminoutermoon@gmail.com", "ops@demo.com"],
        timestamp: NaiveDateTime.new!(~D[2025-11-20], ~T[00:00:00]),
        body: """
        Dear Team,

        Please see attached DO FANU3659913

        Let us know once you schedule the pick up, we will set the delivery appt with the warehouse once Terminal appt is confirmed.

        Thank you!
        """,
        signature: %{
          name: "Charlotte Dominguez",
          email: "dispatch@metalogisticsservices.com",
          phone: "562-346-9996"
        },
        attachments: [
          %{name: "Delivery Order - Charlie's Tires - Sheetl (10).pdf", size: "59.0 KB"}
        ]
      },
      %{
        id: 2,
        sender_name: "Demoemail64937",
        sender_email: "demoemail64937@gmail.com",
        sender_initials: "DE",
        recipients: "to: me, adminoutermoon and 2 more",
        recipient_emails: [
          "me@demo.com",
          "charlotte@metalogisticsservices.com",
          "adminoutermoon@gmail.com"
        ],
        timestamp: NaiveDateTime.new!(~D[2025-11-24], ~T[14:32:00]),
        body: """
        Dear WALMART, Your order has been received for Reference # Nov2025 with MBOL #, our load reference # is B6SV5_NEW_M100117 for your reference. Thank you for your business. On Jan 21, 1970 at 04:53 AM
        """,
        signature: nil,
        attachments: []
      },
      %{
        id: 3,
        sender_name: "Charlie's Dispatch",
        sender_email: "charlestransport808@gmail.com",
        sender_initials: "CD",
        recipients: "to: me, adminoutermoon and 2 more",
        recipient_emails: [
          "me@demo.com",
          "charlotte@metalogisticsservices.com",
          "adminoutermoon@gmail.com"
        ],
        timestamp: NaiveDateTime.new!(~D[2025-12-01], ~T[16:22:00]),
        body: """
        Dear CHARLIE'S TIRES

        We have received your order and are processing the delivery for container FANU3659913. Our driver is scheduled for pickup at APM Elizabeth terminal.

        Container details:
        - Container #: FANU3659913
        - Size: 40' Standard
        - Weight: 42,500 lbs
        - Seal #: SL9982714

        We will update you once the container has been picked up.
        """,
        signature: %{
          name: "Charlie's Dispatch",
          email: "charlestransport808@gmail.com",
          phone: "732-555-0142"
        },
        attachments: []
      }
    ]
  end

  defp generic_thread(email) do
    first_message = %{
      id: 1,
      sender_name: email.from,
      sender_email: email.from_email,
      sender_initials: initials(email.from),
      recipients: "to: me, adminoutermoon and 2 more",
      recipient_emails: ["me@demo.com", "adminoutermoon@gmail.com", email.from_email],
      timestamp: NaiveDateTime.new!(email.date, ~T[12:00:00]),
      body: generate_body(email),
      signature: %{
        name: email.from,
        email: email.from_email,
        phone:
          "562-346-#{:rand.uniform(9999) |> Integer.to_string() |> String.pad_leading(4, "0")}"
      },
      attachments:
        if(email.has_attachment,
          do: [%{name: "#{email.subject}.pdf", size: "#{:rand.uniform(200) + 20}.0 KB"}],
          else: []
        )
    }

    additional =
      if email.thread_count > 1 do
        for i <- 2..email.thread_count do
          is_reply = rem(i, 2) == 0

          %{
            id: i,
            sender_name: if(is_reply, do: "Operations Team", else: email.from),
            sender_email: if(is_reply, do: "operations@moonfreight.com", else: email.from_email),
            sender_initials: if(is_reply, do: "OT", else: initials(email.from)),
            recipients: "to: #{email.from_email}, adminoutermoon",
            recipient_emails: ["me@demo.com", email.from_email],
            timestamp: NaiveDateTime.new!(Date.add(email.date, i * 2), ~T[14:30:00]),
            body: generate_reply_body(email, i),
            signature: nil,
            attachments: []
          }
        end
      else
        []
      end

    [first_message | additional]
  end

  defp generate_body(email) do
    cond do
      "tender" in email.tags ->
        """
        Dear Team,

        Please see attached delivery order for #{email.subject}.

        Kindly schedule the pickup at your earliest convenience. We will coordinate the delivery appointment with the warehouse once the terminal appointment is confirmed.

        Please ensure all documentation is in order before dispatch.

        Thank you for your prompt attention to this matter.
        """

      "quote" in email.tags ->
        """
        Dear Carrier,

        Please advise your best rate for the following shipment:

        Origin: NJ/NY Ports
        Destination: Midwest (Chicago, IL area)
        Equipment: 40' Standard Container
        Commodity: General Merchandise
        Weight: ~42,000 lbs

        Please include all accessorial charges in your quote. We need the rate by end of business today.

        Thank you.
        """

      "empty_return" in email.tags ->
        """
        Team,

        Please find the updated empty return notice below.

        We need to return the following containers as soon as possible to avoid per diem charges:

        Container(s): #{email.subject}
        Return Location: Port Newark / APM Terminal
        Last Free Day: #{Calendar.strftime(Date.add(email.date, 5), "%m/%d/%Y")}

        Please coordinate with the driver for immediate return.
        """

      true ->
        """
        Dear Team,

        #{email.body_preview}

        Please review and take the necessary action. Let us know if you have any questions or need additional information.

        Thank you for your attention to this matter.
        """
    end
  end

  defp generate_reply_body(email, index) do
    cond do
      rem(index, 3) == 0 ->
        """
        Thank you for the update. We have noted the changes and will proceed accordingly.

        Please keep us posted on any further developments regarding #{email.subject}.
        """

      rem(index, 2) == 0 ->
        """
        Hi,

        We have reviewed the information provided. Our team is working on scheduling this.

        We will confirm the appointment details by end of day. Reference: #{email.subject}.
        """

      true ->
        """
        Following up on this request. Could you please provide an update on the current status?

        We need to coordinate with the warehouse and want to ensure timely delivery.

        Thanks.
        """
    end
  end

  # -- Load info generation --

  defp generate_load_info(email) do
    case email.id do
      1 ->
        %{
          assigned_to: ["JR", "MT"],
          loads: [
            %{
              reference: "B6SV5_NEW_M100117",
              container: "FANU3659913",
              customer: "WALMART",
              customer_entity: "Walmart",
              status: "Pending",
              pickup: %{
                name: "APM",
                address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
              },
              delivery: %{
                name: "Walmart",
                address: "1872 New Jersey 88, Brick Township, NJ 08724, US"
              },
              return_terminal: %{
                name: "APM",
                address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
              },
              pickup_appt: nil,
              delivery_appt: nil
            }
          ]
        }

      id when id in [2, 3, 9] ->
        container =
          case id do
            2 -> "TEMU1282305"
            3 -> "TGBU3752218"
            9 -> "DLV-2025-0724"
          end

        %{
          assigned_to: ["CD"],
          loads: [
            %{
              reference: "WM_ORD_#{id}_2025",
              container: container,
              customer: "WALMART",
              customer_entity: "Walmart",
              status: if(id == 9, do: "In Transit", else: "Pending"),
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
              pickup_appt: if(id == 9, do: "07/26/25 08:00 AM", else: nil),
              delivery_appt: if(id == 9, do: "07/28/25 10:00 AM", else: nil)
            }
          ]
        }

      8 ->
        %{
          assigned_to: ["CD", "JR"],
          loads:
            for i <- 1..3 do
              %{
                reference: "DKR_APM_#{i}_2025",
                container: "APMU#{7_700_000 + i}",
                customer: "DECKERS BRANDS",
                customer_entity: "Deckers",
                status: if(i == 1, do: "In Transit", else: "Pending"),
                pickup: %{
                  name: "APM",
                  address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
                },
                delivery: %{
                  name: "Deckers Brands",
                  address: "495 Paterson Plank Rd, Carlstadt, NJ 07072, US"
                },
                return_terminal: %{
                  name: "APM",
                  address: "5080 McLester Street, Elizabeth, NJ 07207, USA"
                },
                pickup_appt: if(i == 1, do: "08/02/25 07:00 AM", else: nil),
                delivery_appt: if(i == 1, do: "08/03/25 09:00 AM", else: nil)
              }
            end
        }

      id when id in [13, 14] ->
        container = if(id == 13, do: "FSAU7009", else: "CHI-2025-0529")

        %{
          assigned_to: ["OT"],
          loads: [
            %{
              reference: "ER_#{id}_2025",
              container: container,
              customer: "EMPTY RETURN",
              customer_entity: "Various",
              status: "Pending",
              pickup: %{
                name: "Customer Yard",
                address:
                  if(id == 14,
                    do: "4200 W 36th Street, Chicago, IL 60632, USA",
                    else: "1200 Port Newark Blvd, Newark, NJ 07114, USA"
                  )
              },
              delivery: %{
                name:
                  if(id == 14, do: "BNSF Logistics Park", else: "Port Newark Container Terminal"),
                address:
                  if(id == 14,
                    do: "26900 S Ridgeland Ave, Elwood, IL 60421, USA",
                    else: "241 Calcutta Street, Newark, NJ 07114, USA"
                  )
              },
              return_terminal: nil,
              pickup_appt: nil,
              delivery_appt: nil
            }
          ]
        }

      _ ->
        %{
          assigned_to: ["OT"],
          loads: [
            %{
              reference: "REF_#{email.id}_2025",
              container: String.slice(email.subject, 0, 15),
              customer: String.upcase(String.slice(email.from, 0, 10)),
              customer_entity: email.from,
              status: "Pending",
              pickup: %{
                name: "Port Newark",
                address: "241 Calcutta Street, Newark, NJ 07114, USA"
              },
              delivery: %{
                name: "Customer Warehouse",
                address: "100 Industrial Pkwy, Edison, NJ 08837, US"
              },
              return_terminal: %{
                name: "Port Newark",
                address: "241 Calcutta Street, Newark, NJ 07114, USA"
              },
              pickup_appt: nil,
              delivery_appt: nil
            }
          ]
        }
    end
  end
end
