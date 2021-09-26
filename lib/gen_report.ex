defmodule GenReport do
  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(file_name) do
    file_name
    |> GenReport.Parser.parse_file()
    |> Enum.reduce(reportacc(), fn [
                                     name,
                                     horas_tb_dia,
                                     dia,
                                     mes,
                                     ano
                                   ],
                                   report ->
      sum_values([name, horas_tb_dia, dia, mes, ano], report)
    end)
  end

  def build_many(filenames) when is_list(filenames) do
    result =
      filenames
      |> Task.async_stream(&build/1)
      |> Enum.reduce(reportacc(), fn {:ok, result}, report -> sum_reports(result, report) end)

    {:ok, result}
  end

  def build_many(filenames) when not is_list(filenames) do
    {:error, "Insira uma lista com os nomes de arquivos"}
  end

  def build_many, do: {:error, "Insira uma lista com os nomes de arquivos"}

  defp sum_reports(
         %{
           "all_hours" => all_hours1,
           "hours_per_month" => hours_per_month1,
           "hours_per_year" => hours_per_year1
         },
         %{
           "all_hours" => all_hours2,
           "hours_per_month" => hours_per_month2,
           "hours_per_year" => hours_per_year2
         }
       ) do
    all_hours = merge_maps(all_hours1, all_hours2)
    hours_per_month = deep_merge(hours_per_month1, hours_per_month2)
    hours_per_year = deep_merge(hours_per_year1, hours_per_year2)

    build_reports(all_hours, hours_per_month, hours_per_year)
  end

  defp deep_merge(m1, m2) do
    Map.merge(m1, m2, fn _k, v1, v2 -> merge_maps(v1, v2) end)
  end

  defp merge_maps(m1, m2) do
    Map.merge(m1, m2, fn _k, v1, v2 -> v1 + v2 end)
  end

  defp sum_values([name, horas_tb_dia, _dia, mes, ano], report) do
    report
    |> sum_all_hours(name, horas_tb_dia)
    |> sum_hours_per_month(name, mes, horas_tb_dia)
    |> sum_hours_per_year(name, ano, horas_tb_dia)
  end

  defp sum_all_hours(report, name, horas_tb_dia) do
    cur_value = Map.get(report["all_hours"], name, 0)

    all_hours = Map.put(report["all_hours"], name, cur_value + horas_tb_dia)

    %{report | "all_hours" => all_hours}
  end

  defp sum_hours_per_month(report, name, month, horas_tb_dia) do
    map_hours_month_for_name = Map.get(report["hours_per_month"], name, defautl_map_months())

    map_hours_month_for_name =
      Map.put(map_hours_month_for_name, month, map_hours_month_for_name[month] + horas_tb_dia)

    map_hours_month_for_name = Map.put(report["hours_per_month"], name, map_hours_month_for_name)

    %{report | "hours_per_month" => map_hours_month_for_name}
  end

  defp sum_hours_per_year(report, name, year, horas_tb_dia) do
    map_hours_month_for_name = Map.get(report["hours_per_year"], name, default_map_years())

    map_hours_month_for_name =
      Map.put(map_hours_month_for_name, year, map_hours_month_for_name[year] + horas_tb_dia)

    map_hours_month_for_name = Map.put(report["hours_per_year"], name, map_hours_month_for_name)

    %{report | "hours_per_year" => map_hours_month_for_name}
  end

  defp reportacc, do: build_reports(%{}, %{}, %{})

  defp build_reports(all_hours, hours_per_month, hours_per_year) do
    %{
      "all_hours" => all_hours,
      "hours_per_month" => hours_per_month,
      "hours_per_year" => hours_per_year
    }
  end

  defp defautl_map_months do
    %{
      "abril" => 0,
      "agosto" => 0,
      "dezembro" => 0,
      "fevereiro" => 0,
      "janeiro" => 0,
      "julho" => 0,
      "junho" => 0,
      "maio" => 0,
      "março" => 0,
      "novembro" => 0,
      "outubro" => 0,
      "setembro" => 0
    }
  end

  defp default_map_years do
    %{
      2016 => 0,
      2017 => 0,
      2018 => 0,
      2019 => 0,
      2020 => 0
    }
  end
end
