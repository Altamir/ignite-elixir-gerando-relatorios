defmodule GenReport do
  def build do
    {:error, "Insira o nome de um arquivo"}
  end

  def build(file_name) do
    {:error, file_name}
  end
end
