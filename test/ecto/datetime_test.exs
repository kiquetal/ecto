defmodule Ecto.DateTest do
  use ExUnit.Case, async: true

  @date %Ecto.Date{year: 2015, month: 12, day: 31}

  test "cast itself" do
    assert Ecto.Date.cast(@date) == {:ok, @date}
  end

  test "cast strings" do
    assert Ecto.Date.cast("2015-12-31") == {:ok, @date}
    assert Ecto.Date.cast("2015-00-23") == :error
    assert Ecto.Date.cast("2015-13-23") == :error
    assert Ecto.Date.cast("2015-01-00") == :error
    assert Ecto.Date.cast("2015-01-32") == :error

    assert Ecto.Date.cast("2015-12-31 23:50:07") == {:ok, @date}
    assert Ecto.Date.cast("2015-12-31T23:50:07") == {:ok, @date}
    assert Ecto.Date.cast("2015-12-31T23:50:07Z") == {:ok, @date}
    assert Ecto.Date.cast("2015-12-31T23:50:07.000Z") == {:ok, @date}
    assert Ecto.Date.cast("2015-12-31P23:50:07") == :error

    assert Ecto.Date.cast("2015-12-31T23:50:07.008") == {:ok, @date}
    assert Ecto.Date.cast("2015-12-31T23:50:07.008Z") == {:ok, @date}
  end

  test "cast maps" do
    assert Ecto.Date.cast(%{"year" => "2015", "month" => "12", "day" => "31"}) ==
           {:ok, @date}
    assert Ecto.Date.cast(%{year: 2015, month: 12, day: 31}) ==
           {:ok, @date}
    assert Ecto.Date.cast(%{"year" => "2015", "month" => "", "day" => "31"}) ==
           :error
    assert Ecto.Date.cast(%{"year" => "2015", "month" => nil, "day" => "31"}) ==
           :error
    assert Ecto.Date.cast(%{"year" => "2015", "month" => nil}) ==
           :error
  end

  test "cast erl date" do
    assert Ecto.Date.cast({2015, 12, 31}) == {:ok, @date}
    assert Ecto.Date.cast({2015, 13, 31}) == :error
  end

  test "dump itself into a date triplet" do
    assert Ecto.Date.dump(@date) == {:ok, {2015, 12, 31}}
    assert Ecto.Date.dump({2015, 12, 31}) == :error
  end

  test "load a date triplet" do
    assert Ecto.Date.load({2015, 12, 31}) == {:ok, @date}
    assert Ecto.Date.load(@date) == :error
  end

  test "to_string" do
    assert to_string(@date) == "2015-12-31"
    assert Ecto.Date.to_string(@date) == "2015-12-31"
  end

  test "to_iso8601" do
    assert Ecto.Date.to_iso8601(@date) == "2015-12-31"
  end

  test "to_erl and from_erl" do
    assert @date |> Ecto.Date.to_erl |> Ecto.Date.from_erl == @date
  end

  test "inspect protocol" do
    assert inspect(@date) == "#Ecto.Date<2015-12-31>"
  end
end

defmodule Ecto.TimeTest do
  use ExUnit.Case, async: true

  @time %Ecto.Time{hour: 23, min: 50, sec: 07, usec: 0}
  @time_zero %Ecto.Time{hour: 23, min: 50, sec: 0, usec: 0}
  @time_usec %Ecto.Time{hour: 12, min: 40, sec: 33, usec: 30000}

  test "cast itself" do
    assert Ecto.Time.cast(@time) == {:ok, @time}
    assert Ecto.Time.cast(@time_zero) ==  {:ok, @time_zero}
  end

  test "cast strings" do
    assert Ecto.Time.cast("23:50:07") == {:ok, @time}
    assert Ecto.Time.cast("23:50:07Z") == {:ok, @time}

    assert Ecto.Time.cast("23:50:07.030")
      == {:ok, %{@time | usec: 30000}}
    assert Ecto.Time.cast("23:50:07.123456")
      == {:ok, %{@time | usec: 123456}}
    assert Ecto.Time.cast("23:50:07.123456Z")
      == {:ok, %{@time | usec: 123456}}
    assert Ecto.Time.cast("23:50:07.000123Z")
      == {:ok, %{@time | usec: 123}}

    assert Ecto.Time.cast("24:01:01") == :error
    assert Ecto.Time.cast("00:61:00") == :error
    assert Ecto.Time.cast("00:00:61") == :error
    assert Ecto.Time.cast("00:00:009") == :error
    assert Ecto.Time.cast("00:00:00.A00") == :error
  end

  test "cast maps" do
    assert Ecto.Time.cast(%{"hour" => "23", "min" => "50", "sec" => "07"}) ==
           {:ok, @time}
    assert Ecto.Time.cast(%{hour: 23, min: 50, sec: 07}) ==
           {:ok, @time}
    assert Ecto.Time.cast(%{"hour" => "23", "min" => "50"}) ==
           {:ok, @time_zero}
    assert Ecto.Time.cast(%{hour: 23, min: 50}) ==
           {:ok, @time_zero}
    assert Ecto.Time.cast(%{hour: 12, min: 40, sec: 33, usec: 30_000}) ==
           {:ok, @time_usec}
    assert Ecto.Time.cast(%{"hour" => 12, "min" => 40, "sec" => 33, "usec" => 30_000}) ==
           {:ok, @time_usec}
    assert Ecto.Time.cast(%{"hour" => "", "min" => "50"}) ==
           :error
    assert Ecto.Time.cast(%{hour: 23, min: nil}) ==
           :error
  end

  test "cast tuple" do
    assert Ecto.Time.cast({23, 50, 07}) == {:ok, @time}
    assert Ecto.Time.cast({12, 40, 33, 30000}) == {:ok, @time_usec}
    assert Ecto.Time.cast({00, 61, 33}) == :error
  end

  test "dump itself into a time tuple" do
    assert Ecto.Time.dump(@time) == {:ok, {23, 50, 7, 0}}
    assert Ecto.Time.dump(@time_usec) == {:ok, {12, 40, 33, 30000}}
    assert Ecto.Time.dump({23, 50, 07}) == :error
  end

  test "load tuple" do
    assert Ecto.Time.load({23, 50, 07}) == {:ok, @time}
    assert Ecto.Time.load({12, 40, 33, 30000}) == {:ok, @time_usec}
    assert Ecto.Time.load(@time) == :error
  end

  test "to_string" do
    assert to_string(@time) == "23:50:07"
    assert Ecto.Time.to_string(@time) == "23:50:07"

    assert to_string(@time_usec) == "12:40:33.030000"
    assert Ecto.Time.to_string(@time_usec) == "12:40:33.030000"

    assert to_string(%Ecto.Time{hour: 1, min: 2, sec: 3, usec: 4})
           == "01:02:03.000004"
    assert Ecto.Time.to_string(%Ecto.Time{hour: 1, min: 2, sec: 3, usec: 4})
           == "01:02:03.000004"
  end

  test "to_iso8601" do
    assert Ecto.Time.to_iso8601(@time) == "23:50:07"
    assert Ecto.Time.to_iso8601(@time_usec) == "12:40:33.030000"
  end

  test "to_erl and from_erl" do
    assert @time |> Ecto.Time.to_erl |> Ecto.Time.from_erl == @time
  end

  test "inspect protocol" do
    assert inspect(@time) == "#Ecto.Time<23:50:07>"
    assert inspect(@time_usec) == "#Ecto.Time<12:40:33.030000>"
  end
end

defmodule Ecto.DateTimeTest do
  use ExUnit.Case, async: true

  @datetime %Ecto.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07, usec: 0}
  @datetime_zero %Ecto.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 0, usec: 0}
  @datetime_usec %Ecto.DateTime{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07, usec: 8000}
  @datetime_notime %Ecto.DateTime{year: 2015, month: 1, day: 23, hour: 0, min: 0, sec: 0, usec: 0}

  test "cast itself" do
    assert Ecto.DateTime.cast(@datetime) == {:ok, @datetime}
    assert Ecto.DateTime.cast(@datetime_usec) == {:ok, @datetime_usec}
  end

  test "cast strings" do
    assert Ecto.DateTime.cast("2015-01-23 23:50:07") == {:ok, @datetime}
    assert Ecto.DateTime.cast("2015-01-23T23:50:07") == {:ok, @datetime}
    assert Ecto.DateTime.cast("2015-01-23T23:50:07Z") == {:ok, @datetime}
    assert Ecto.DateTime.cast("2015-01-23T23:50:07.000Z") == {:ok, @datetime}
    assert Ecto.DateTime.cast("2015-01-23P23:50:07") == :error

    assert Ecto.DateTime.cast("2015-01-23T23:50:07.008") == {:ok, @datetime_usec}
    assert Ecto.DateTime.cast("2015-01-23T23:50:07.008Z") == {:ok, @datetime_usec}
    assert Ecto.DateTime.cast("2015-01-23T23:50:07.008000789") == {:ok, @datetime_usec}
  end

  test "cast maps" do
    assert Ecto.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "23", "min" => "50", "sec" => "07"}) ==
           {:ok, @datetime}

    assert Ecto.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: 50, sec: 07}) ==
           {:ok, @datetime}

    assert Ecto.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "23", "min" => "50"}) ==
           {:ok, @datetime_zero}

    assert Ecto.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: 50}) ==
           {:ok, @datetime_zero}

    assert Ecto.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23,
                                min: 50, sec: 07, usec: 8_000}) ==
           {:ok, @datetime_usec}

    assert Ecto.DateTime.cast(%{"year" => 2015, "month" => 1, "day" => 23,
                                "hour" => 23, "min" => 50, "sec" => 07,
                                "usec" => 8_000}) ==
           {:ok, @datetime_usec}

    assert Ecto.DateTime.cast(%{"year" => "2015", "month" => "1", "day" => "23",
                                "hour" => "", "min" => "50"}) ==
           :error

    assert Ecto.DateTime.cast(%{year: 2015, month: 1, day: 23, hour: 23, min: nil}) ==
           :error
  end

  test "cast tuple" do
    assert Ecto.DateTime.cast({{2015, 1, 23}, {23, 50, 07}}) == {:ok, @datetime}
    assert Ecto.DateTime.cast({{2015, 1, 23}, {23, 50, 07, 8000}}) == {:ok, @datetime_usec}
    assert Ecto.DateTime.cast({{2015, 1, 23}, {25, 50, 07, 8000}}) == :error
  end

  test "dump itself to a tuple" do
    assert Ecto.DateTime.dump(@datetime) == {:ok, {{2015, 1, 23}, {23, 50, 07, 0}}}
    assert Ecto.DateTime.dump(@datetime_usec) == {:ok, {{2015, 1, 23}, {23, 50, 07, 8000}}}
    assert Ecto.DateTime.dump({{2015, 1, 23}, {23, 50, 07}}) == :error
  end

  test "load tuple" do
    assert Ecto.DateTime.load({{2015, 1, 23}, {23, 50, 07}}) == {:ok, @datetime}
    assert Ecto.DateTime.load({{2015, 1, 23}, {23, 50, 07, 8000}}) == {:ok, @datetime_usec}
    assert Ecto.DateTime.load(@datetime) == :error
  end

  test "from_date" do
    assert Ecto.DateTime.from_date(%Ecto.Date{year: 2015, month: 1, day: 23}) == @datetime_notime
  end

  test "to_string" do
    assert to_string(@datetime) == "2015-01-23 23:50:07"
    assert Ecto.DateTime.to_string(@datetime) == "2015-01-23 23:50:07"

    assert to_string(@datetime_usec) == "2015-01-23 23:50:07.008000"
    assert Ecto.DateTime.to_string(@datetime_usec) == "2015-01-23 23:50:07.008000"
  end

  test "to_iso8601" do
    assert Ecto.DateTime.to_iso8601(@datetime) == "2015-01-23T23:50:07Z"
    assert Ecto.DateTime.to_iso8601(@datetime_usec) == "2015-01-23T23:50:07.008000Z"
  end

  test "to_erl and from_erl" do
    assert @datetime |> Ecto.DateTime.to_erl |> Ecto.DateTime.from_erl == @datetime
  end

  test "inspect protocol" do
    assert inspect(@datetime) == "#Ecto.DateTime<2015-01-23T23:50:07Z>"
    assert inspect(@datetime_usec) == "#Ecto.DateTime<2015-01-23T23:50:07.008000Z>"
  end
end
