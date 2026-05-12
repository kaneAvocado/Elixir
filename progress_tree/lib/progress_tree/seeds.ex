defmodule ProgressTree.Seeds do
  @moduledoc "Demo data for NII Progress."

  alias ProgressTree.Repo
  alias ProgressTree.Employees.Employee
  alias ProgressTree.Knowledge
  alias ProgressTree.Knowledge.{TechGene, TechRelation}

  def run do
    Repo.delete_all(TechRelation)
    Repo.delete_all(TechGene)
    Repo.delete_all(Employee)

    employees = [
      %{full_name: "Иванов Иван Иванович", department: "Отдел №5", position: "ведущий инженер", hired_at: ~D[1975-03-01]},
      %{full_name: "Петрова Мария Сергеевна", department: "Отдел №5", position: "инженер-конструктор", hired_at: ~D[1998-09-15]},
      %{full_name: "Сидоров Алексей Петрович", department: "Отдел №12", position: "зав. лабораторией", hired_at: ~D[1982-06-20], fired_at: ~D[2019-12-31]},
      %{full_name: "Козлова Елена Викторовна", department: "Лаборатория 3", position: "старший научный сотрудник", hired_at: ~D[2005-01-10]},
      %{full_name: "Морозов Дмитрий Андреевич", department: "Отдел №7", position: "инженер", hired_at: ~D[2012-04-01]}
    ]

    emp_map =
      for attrs <- employees, into: %{} do
        {:ok, e} = %Employee{} |> Employee.changeset(attrs) |> Repo.insert()
        {attrs.full_name, e}
      end

    ivanov = emp_map["Иванов Иван Иванович"]
    petrova = emp_map["Петрова Мария Сергеевна"]
    sidorov = emp_map["Сидоров Алексей Петрович"]
    kozlova = emp_map["Козлова Елена Викторовна"]
    morozov = emp_map["Морозов Дмитрий Андреевич"]

    genes_spec = [
      {"Усилитель ПЧ-400 прототип", "НИИ-1987-001", "чертеж", "Отдел №5", 1987, ivanov.id},
      {"Усилитель ПЧ-400-1", "НИИ-2003-014", "спецификация", "Отдел №5", 2003, petrova.id},
      {"Усилитель ПЧ-400-М", "НИИ-2020-088", "спецификация", "Отдел №12", 2020, kozlova.id},
      {"Методика расчёта ПЧ-линий", "НИИ-1995-022", "методичка", "Лаборатория 3", 1995, sidorov.id},
      {"Модуль питания МП-12", "НИИ-2015-042", "чертеж", "Лаборатория 3", 2015, kozlova.id},
      {"Система охлаждения СО-8", "НИИ-2010-031", "чертеж", "Отдел №7", 2010, morozov.id},
      {"Комплекс ПЧ-400-К", "НИИ-2022-101", "отчет", "Отдел №12", 2022, kozlova.id},
      {"Усилитель ПЧ-400-Б (форк)", "НИИ-2008-055", "спецификация", "Отдел №7", 2008, morozov.id},
      {"Отчёт НИР-412", "НИИ-2018-077", "отчет", "Отдел №5", 2018, petrova.id},
      {"Блок коммутации БК-3", "НИИ-2001-009", "спецификация", "Отдел №5", 2001, ivanov.id}
    ]

    gene_list =
      for {title, inv, dtype, dept, year, author_id} <- genes_spec do
        {:ok, g} =
          Knowledge.create_gene(%{
            title: title,
            inventory_number: inv,
            doc_type: dtype,
            department: dept,
            year: year,
            author_id: author_id,
            status: "актуально"
          })

        g
      end

    [g87, g03, g20, g95, g15, g10, g22, g08, g18, g01] = gene_list

    relations = [
      {g87.id, g03.id, "наследование"},
      {g03.id, g20.id, "наследование"},
      {g95.id, g03.id, "вдохновение"},
      {g15.id, g20.id, "сборка"},
      {g10.id, g15.id, "сборка"},
      {g01.id, g03.id, "сборка"},
      {g03.id, g08.id, "форк"},
      {g03.id, g18.id, "наследование"},
      {g20.id, g22.id, "наследование"},
      {g10.id, g22.id, "сборка"},
      {g15.id, g22.id, "сборка"}
    ]

    for {parent_id, child_id, type} <- relations do
      {:ok, _} =
        Knowledge.create_relation(%{
          parent_id: parent_id,
          child_id: child_id,
          relation_type: type
        })
    end

    :ok
  end
end
