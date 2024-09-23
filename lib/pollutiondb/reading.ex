require Ecto.Query

defmodule Pollutiondb.Reading do
  use Ecto.Schema

  schema "readings" do
    field(:type, :string)
    field(:value, :float)
    field(:date, :date)
    field(:time, :time)
    belongs_to(:station, Pollutiondb.Station)
  end

  def add_now(station, type, value) do
    %Pollutiondb.Reading{
      type: type,
      value: value,
      date: Date.utc_today(),
      time: Time.truncate(Time.utc_now(), :second),
      station: station
    }
    |> Pollutiondb.Repo.insert()
  end

  def add(station, type, value, date, time) do
    %Pollutiondb.Reading{
      type: type,
      value: value,
      date: date,
      time: Time.truncate(time, :second),
      station: station
    }
    |> Pollutiondb.Repo.insert()
  end

  def find_by_date(date) do
    Ecto.Query.from(r in Pollutiondb.Reading,
      limit: 10,
      order_by: [desc: r.date, desc: r.time],
      where: r.date == ^date
    )
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
  end

  def get_all do
    Ecto.Query.from(r in Pollutiondb.Reading)
    |> Pollutiondb.Repo.all()
  end

  def get_latest do
    Ecto.Query.from(r in Pollutiondb.Reading, limit: 10, order_by: [desc: r.date, desc: r.time])
    |> Pollutiondb.Repo.all()
    |> Pollutiondb.Repo.preload(:station)
  end
end
