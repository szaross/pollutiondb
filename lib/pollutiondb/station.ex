require Ecto.Query

defmodule Pollutiondb.Station do
  use Ecto.Schema

  schema "stations" do
    field(:name, :string)
    field(:lon, :float)
    field(:lat, :float)
    has_many(:readings, Pollutiondb.Reading)
  end

  def add(station) do
    Pollutiondb.Repo.insert(station)
  end

  def add(name, lon, lat) do
    %Pollutiondb.Station{}
    |> chs(%{name: name, lon: lon, lat: lat})
    |> Pollutiondb.Repo.insert()
  end

  def get_all do
    Pollutiondb.Repo.all(Pollutiondb.Station)
  end

  def get_by_id(id) do
    Pollutiondb.Repo.get(Pollutiondb.Station, id)
  end

  def remove(station) do
    Pollutiondb.Repo.delete(station)
  end

  def find_by_name(name) do
    Pollutiondb.Repo.all(Ecto.Query.where(Pollutiondb.Station, name: ^name))
  end

  def find_that_include(name) do
    str = "%" <> name <> "%"

    Ecto.Query.from(s in Pollutiondb.Station,
      where: like(s.name, ^str)
    )
    |> Pollutiondb.Repo.all()
  end

  def find_by_location(lon, lat) do
    Ecto.Query.from(s in Pollutiondb.Station,
      where: s.lon == ^lon,
      where: s.lat == ^lat
    )
    |> Pollutiondb.Repo.all()
  end

  def find_by_location_range(lon_min, lon_max, lat_min, lat_max) do
    Ecto.Query.from(s in Pollutiondb.Station,
      where: s.lon <= ^lon_max,
      where: s.lat <= ^lat_max,
      where: s.lon >= ^lon_min,
      where: s.lat >= ^lat_min
    )
    |> Pollutiondb.Repo.all()
  end

  def update_name(station, newname) do
    station
    |> chs(%{name: newname})
    |> Pollutiondb.Repo.update()
  end

  defp chs(station, changes_map) do
    station
    |> Ecto.Changeset.cast(changes_map, [:name, :lon, :lat])
    |> Ecto.Changeset.validate_required([:name])
    |> Ecto.Changeset.validate_length(:name, min: 4)
    |> Ecto.Changeset.validate_number(:lon, less_than: 180, greater_than: -180)
  end

  def generate_stations do
    for station <- [
          %Pollutiondb.Station{name: "s1", lon: 1.1, lat: 1.1},
          %Pollutiondb.Station{name: "s2", lon: 2.1, lat: 2.1},
          %Pollutiondb.Station{name: "s3", lon: 3.1, lat: 3.1},
          %Pollutiondb.Station{name: "s4", lon: 4.1, lat: 4.1}
        ] do
      Pollutiondb.Station.add(station)
    end
  end
end
