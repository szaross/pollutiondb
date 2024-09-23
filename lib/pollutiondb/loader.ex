defmodule ParseLoader do
  def parse_line(line) do
    [
      datetime_str,
      pollutionType_str,
      pollutionLevel_str,
      stationId_str,
      stationName_str,
      location_str
    ] = line |> String.split(";")

    %{
      :location =>
        location_str
        |> String.split(",")
        |> Enum.map(&String.to_float/1)
        |> List.to_tuple(),
      :stationId => stationId_str |> String.to_integer(),
      :stationName => stationName_str,
      :pollutionType => pollutionType_str,
      :pollutionLevel => pollutionLevel_str |> String.to_float(),
      :datetime => {get_date(datetime_str), get_time(datetime_str)}
    }
  end

  defp get_date(line) do
    line
    |> String.slice(0..9)
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp get_time(line) do
    line
    |> String.slice(11..18)
    |> String.split(":")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def identifyStations(datalist) do
    datalist
    |> Enum.uniq_by(&{&1.location, &1.stationId, &1.stationName})
  end
end

defmodule PollutionDataLoader do
  def loadData(data) do
    ret = PollutionDataLoader.loadStations(data) |> Enum.filter(&(&1 != :ok))
    ret = (ret ++ PollutionDataLoader.loadValues(data)) |> Enum.filter(&(&1 != :ok))

    case ret do
      [] -> :ok
      x -> x
    end
  end

  def loadStations(data) do
    station_names =
      data
      |> ParseLoader.identifyStations()
      |> Enum.map(&%{:name => "#{&1.stationId} #{&1.stationName}", :location => &1.location})

    f = fn s ->
      {lon, lat} = s.location
      Pollutiondb.Station.add(s.name, lon, lat)
    end

    station_names |> Enum.map(f)
  end

  def loadValues(data) do
    f2 = fn data ->
      {lon, lat} = data.location

      [s | _] = Pollutiondb.Station.find_by_location(lon, lat)
      {ddate, dtime} = data.datetime
      {:ok, date} = Date.from_erl(ddate)
      {:ok, time} = Time.from_erl(dtime)
      Pollutiondb.Reading.add(s, data.pollutionType, data.pollutionLevel, date, time)
    end

    #    f2 =
    #      &:pollution_gen_server.add_value(
    #        &1.location,
    #        &1.datetime,
    #        &1.pollutionType,
    #        &1.pollutionLevel
    #      )

    data |> Enum.map(f2)
  end

  def loadCsv do
    data =
      File.read!("C:\\Users\\Szymon\\Downloads\\AirlyData-ALL-50k.csv")
      |> String.split("\n")

    parsed_data = data |> Enum.map(&ParseLoader.parse_line/1)
    PollutionDataLoader.loadData(parsed_data)
  end
end
