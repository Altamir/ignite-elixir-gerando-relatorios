defmodule GenReportTest do
  use ExUnit.Case

  alias GenReport
  alias GenReport.Support.ReportFixture

  @file_name "gen_report.csv"

  @file_names ["part_1.csv", "part_2.csv", "part_3.csv"]

  describe "build/1" do
    test "When passing file name return a report" do
      response = GenReport.build(@file_name)

      assert response == ReportFixture.build()
    end

    test "When no filename was given, returns an error" do
      response = GenReport.build()

      assert response == {:error, "Insira o nome de um arquivo"}
    end
  end

  describe "build_many/1" do
    test "When passing list of file name return a report" do
      response = GenReport.build_many(@file_names)
      expect = ReportFixture.build()
      assert response == {:ok, expect}
    end

    test "When no list of filenames was given, returns an error" do
      response = GenReport.build_many(@file_name)

      assert response == {:error, "Insira uma lista com os nomes de arquivos"}
    end

    test "When no parameters was given, returns an error" do
      response = GenReport.build_many()

      assert response == {:error, "Insira uma lista com os nomes de arquivos"}
    end
  end
end
