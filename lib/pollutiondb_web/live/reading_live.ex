defmodule PollutiondbWeb.ReadingLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Reading
  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        readings: Reading.get_latest(),
        date: Date.utc_today(),
        date_insert: Date.utc_today(),
        stations: Station.get_all(),
        station_id: 1,
        type: "",
        value: 0.0,
        time: Time.utc_now()
      )

    {:ok, socket}
  end

  def handle_event(
        "update",
        %{"date" => date},
        socket
      ) do
    date =
      if date == "" do
        Date.utc_today()
      else
        date
      end

    readings = Reading.find_by_date(date)

    socket =
      assign(socket,
        readings: readings,
        date: date
      )

    {:noreply, socket}
  end

  def handle_event(
        "insert",
        %{
          "type" => type,
          "value" => value,
          "date_insert" => date_insert,
          "time" => time,
          "station_id" => station_id
        },
        socket
      ) do
    {:ok, t_time} = Time.from_iso8601(time)
    {:ok, t_date} = Date.from_iso8601(date_insert)

    {value, _} = Float.parse(value)

    Station.get_by_id(station_id)
    |> Reading.add(type, value, t_date, t_time)

    socket =
      assign(socket,
        readings: Reading.get_latest(),
        date: date_insert,
        date_insert: date_insert,
        stations: Station.get_all(),
        station_id: String.to_integer(station_id),
        type: type,
        value: value,
        time: time
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <!--
    // v0 by Vercel.
    // https://v0.dev/t/Z53qnGGaccm
    -->
    <div class="w-full max-w-3xl mx-auto space-y-8">
      <div class="text-center space-y-2">
        <h1 class="text-3xl font-bold">Pollution Data Submission</h1>
        
        <p class="text-gray-500">Submit your pollution data readings below.</p>
      </div>
      
      <form id="xw42maxeizd" class="space-y-4" phx-submit="insert">
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="type"
            >
              Type
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="type"
              placeholder="Enter pollution type"
              required=""
              value={@type}
              name="type"
              type="text"
            />
          </div>
          
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="value"
            >
              Value
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="value"
              placeholder="Enter pollution value"
              required=""
              type="number"
              value={@value}
              name="value"
              step="0.1"
            />
          </div>
        </div>
        
        <div class="grid grid-cols-2 gap-4">
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="date"
            >
              Date
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="date_insert"
              required=""
              type="date"
              value={@date_insert}
              name="date_insert"
            />
          </div>
          
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="time"
            >
              Time
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="time"
              required=""
              type="time"
              value={@time}
              name="time"
              step="1"
            />
          </div>
        </div>
        
        <div class="space-y-2">
          <label
            class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
            for="station_id"
          >
            Station
          </label>
          
          <select
            required=""
            name="station_id"
            class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
          >
            <%= for station <- @stations do %>
              <%= if station.id == @station_id do %>
                <option label={station.name} value={station.id} selected />
              <% else %>
                <option label={station.name} value={station.id} />
              <% end %>
            <% end %>
          </select>
        </div>
        
        <button
          class="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2 w-full"
          type="submit"
        >
          Submit
        </button>
      </form>
      
      <div class="flex items-center justify-between mb-4">
        <h2 class="text-2xl font-bold">Pollution Data</h2>
        
        <div class="flex items-center space-x-2">
          <form phx-change="update">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="filter-date"
            >
              Filter by date:
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="filter-date"
              type="date"
              value={@date}
              name="date"
            />
          </form>
        </div>
      </div>
      
      <div class="relative w-full overflow-auto">
        <table class="w-full caption-bottom text-sm">
          <thead class="[&amp;_tr]:border-b">
            <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0 ">
                Name
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0 ">
                Type
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0 ">
                Value
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                Date
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                Time
              </th>
            </tr>
          </thead>
          
          <tbody class="[&amp;_tr:last-child]:border-0">
            <%= for reading <- @readings do %>
              <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= reading.station.name %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= reading.type %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= reading.value %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= reading.date %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0">
                  <%= reading.time %>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
