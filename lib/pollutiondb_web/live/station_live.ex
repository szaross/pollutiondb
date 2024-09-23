defmodule PollutiondbWeb.StationLive do
  use PollutiondbWeb, :live_view

  alias Pollutiondb.Station

  def mount(_params, _session, socket) do
    socket = assign(socket, stations: Station.get_all(), name: "", lat: "", lon: "", query: "")
    {:ok, socket}
  end

  def handle_event("query", %{"query" => name}, socket) do
    stations =
      if name == "" do
        Station.get_all()
      else
        Station.find_that_include(name)
        |> List.wrap()
      end

    socket = assign(socket, stations: stations, query: name, name: "", lat: "", lon: "")

    {:noreply, socket}
  end

  def handle_event("insert", %{"name" => name, "lat" => lat, "lon" => lon}, socket) do
    Station.add(%Station{name: name, lat: to_float(lat, 0.0), lon: to_float(lon, 0.0)})
    socket = assign(socket, name: name, lat: lat, lon: lon)
    {:noreply, socket}
  end

  def to_float(val, default) do
    case Float.parse(val) do
      :error -> default
      {res, _} -> res
    end
  end

  def render(assigns) do
    ~H"""
    <div class="w-full max-w-3xl mx-auto space-y-8">
      <div class="text-center space-y-2">
        <h1 class="text-3xl font-bold">Create new station</h1>
      </div>
      
      <form id="station-form" class="space-y-4" phx-submit="insert">
        <div class="grid grid-cols-3 gap-4">
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="name"
            >
              Name
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="name"
              name="name"
              type="text"
              value={@name}
            />
          </div>
          
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="lat"
            >
              Lat
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="lat"
              name="lat"
              type="number"
              step="0.1"
              value={@lat}
            />
          </div>
          
          <div class="space-y-2">
            <label
              class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
              for="lon"
            >
              Lon
            </label>
            
            <input
              class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              id="lon"
              name="lon"
              type="number"
              step="0.1"
              value={@lon}
            />
          </div>
        </div>
        
        <button
          class="inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 bg-primary text-primary-foreground hover:bg-primary/90 h-10 px-4 py-2 w-full"
          type="submit"
        >
          Submit
        </button>
      </form>
      
      <div class="text-center space-y-2">
        <h2 class="text-2xl font-bold">Search</h2>
      </div>
      
      <form id="search-form" class="space-y-4" phx-change="query">
        <div class="space-y-2">
          <label
            class="text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
            for="query"
          >
            Query
          </label>
          
          <input
            class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            id="query"
            name="query"
            type="text"
            value={@query}
          />
        </div>
      </form>
      
      <div class="relative w-full overflow-auto">
        <table class="w-full caption-bottom text-sm">
          <thead class="[&amp;_tr]:border-b">
            <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                Name
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                Longitude
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                Latitude
              </th>
              
              <th class="h-12 px-4 text-left align-middle font-medium text-muted-foreground [&amp;:has([role=checkbox])]:pr-0">
                ID
              </th>
            </tr>
          </thead>
          
          <tbody class="[&amp;_tr:last-child]:border-0">
            <%= for station <- @stations do %>
              <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= station.name %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= station.lon %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 ">
                  <%= station.lat %>
                </td>
                
                <td class="p-4 align-middle [&amp;:has([role=checkbox])]:pr-0 "><%= station.id %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
