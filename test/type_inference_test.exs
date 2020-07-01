defmodule TypeInferenceTest do
  use ExUnit.Case
  doctest ABACthem
  alias ABACthem.{Types}

  test "infer basic types" do
    assert [] = Types.infer_type(%{})

    assert [%{data_type: "string", name: "id", value: "alice"}] =
             Types.infer_type(%{"id" => "alice"})

    assert [
             %{data_type: "string", name: "id", value: "alice"},
             %{data_type: "string", name: "name", value: "Alice"}
           ] = Types.infer_type(%{"id" => "alice", "name" => "Alice"})

    assert [%{data_type: "number", name: "age", value: 20}] = Types.infer_type(%{"age" => 20})

    assert [%{data_type: "number", name: "reputation", value: 4.0}] =
             Types.infer_type(%{"reputation" => 4.0})

    assert [%{data_type: "range", name: "year", value: %{max: 2030}}] =
             Types.infer_type(%{"year" => %{"max" => 2030}})
  end

  test "infer object type (not recursive)" do
    assert [
             %{
               data_type: "object",
               name: "pricing",
               value: %{"maxPrice" => 5}
             }
           ] = Types.infer_type(%{"pricing" => %{"maxPrice" => 5}})
  end

  test "infer object type (recursive)" do
    assert [
             %{
               data_type: "object",
               name: "pricing",
               value: []
             }
           ] = Types.infer_type(%{"pricing" => %{}}, true)

    assert [
             %{
               data_type: "object",
               name: "pricing",
               value: [%{data_type: "number", name: "maxPrice", value: 5}]
             }
           ] = Types.infer_type(%{"pricing" => %{"maxPrice" => 5}}, true)

    assert [
             %{
               data_type: "object",
               name: "geolocation",
               value: [
                 %{data_type: "number", name: "number", value: 10},
                 %{data_type: "string", name: "street", value: "St. 1"}
               ]
             }
           ] =
             Types.infer_type(
               %{
                 "geolocation" => %{"street" => "St. 1", "number" => 10}
               },
               true
             )
  end

  test "infer object type with nested range (recursive)" do
    assert [
             %{
               data_type: "object",
               name: "geolocation",
               value: [
                 %{data_type: "range", name: "number", value: %{min: 10, max: 20}},
                 %{data_type: "string", name: "street", value: "St. 1"}
               ]
             }
           ] =
             Types.infer_type(
               %{
                 "geolocation" => %{"street" => "St. 1", "number" => %{"min" => 10, "max" => 20}}
               },
               true
             )
  end
end
