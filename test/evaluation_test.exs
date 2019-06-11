defmodule EvaluationTest do
  use ExUnit.Case
  alias ABACthem.{Attr, Policy}

  test "representing PM" do
    _policies = [
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Group", value: "Group1"}
        ],
        operations: ["write"],
        object_attrs: [
          %Attr{data_type: "string", name: "Project", value: "Project1"}
        ]
      },
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Group", value: "Group2"}
        ],
        operations: ["write"],
        object_attrs: [
          %Attr{data_type: "string", name: "Project", value: "Project2"}
        ]
      },
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Group", value: "Group2"}
        ],
        operations: ["read", "write"],
        object_attrs: [
          %Attr{data_type: "string", name: "Project", value: "Gr2-Secret"}
        ]
      },
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Group", value: "Division"}
        ],
        operations: ["read"],
        object_attrs: [
          %Attr{data_type: "string", name: "Project", value: "Projects"}
        ]
      }
    ]

    # Poison.encode!(policies, pretty: true) |> IO.puts()
  end

  describe "representing HGABABACthem" do
    test "case 1" do
      [
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Undergrad"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Book"},
            %Attr{data_type: "string", name: "Restricted", value: "False"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Undergrad"},
            %Attr{data_type: "string", name: "EnrolledInCourse", value: "CS101"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Course", value: "CS101"}
          ]
        }
      ]
      # |> Policy.simple_encode() |> IO.puts

      # |> Policy.convert_attrs_to_list()
      # |> Poison.encode!(pretty: true)
      # |> IO.puts()

    end

    test "case 2" do
      [
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Gradstudent"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Periodical"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Gradstudent"},
            %Attr{data_type: "string", name: "TeachingAssistant", value: "CS101"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Course", value: "CS101"}
          ]
        }
      ]

      # |> Policy.convert_attrs_to_list()
      # |> Poison.encode!(pretty: true)
      # |> IO.puts()
    end

    test "case 3" do
      [
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Faculty"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Book"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Faculty"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Periodical"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Faculty"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "CourseMaterial"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Faculty"},
            %Attr{data_type: "string", name: "Department", value: "ComputerScience"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "ArchivedRecords"},
            %Attr{data_type: "string", name: "Department", value: "ComputerScience"}
          ]
        }
      ]

      # |> Policy.convert_attrs_to_list()
      # |> Poison.encode!(pretty: true)
      # |> IO.puts()
    end

    test "case 4" do
      [
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Staff"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "*"}
          ],
          context_attrs: [
            %Attr{data_type: "time_interval", name: "DateTime", value: "* * 8-17 * * *"},
            %Attr{data_type: "range", name: "Weekday", value: %{min: 1, max: 5}}
          ]
        }
      ]

      # |> Policy.convert_attrs_to_list()
      # |> Poison.encode!(pretty: true)
      # |> IO.puts()
    end

    test "case 5" do
      [
        %Policy{
          user_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Undergrad"},
            %Attr{data_type: "string", name: "EnrolledInCourse", value: "ComputerScience"}
          ],
          operations: ["check_out_book"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "Periodicals"}
          ],
          context_attrs: [
            %Attr{data_type: "ip_range", name: "UserIpAddress", value: "192.168.*.*"}
          ]
        }
      ]

      # |> Policy.convert_attrs_to_list()
      # |> Poison.encode!(pretty: true)
      # |> IO.puts()
    end
  end

  @tag :skip
  test "HGABABACthem case 1 >> modified with 'variable'" do
    _policies = [
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Type", value: "Undergrad"}
        ],
        operations: ["check_out_book"],
        object_attrs: [
          %Attr{data_type: "string", name: "Type", value: "Book"},
          %Attr{data_type: "string", name: "Restricted", value: "False"}
        ]
      },
      %Policy{
        user_attrs: [
          %Attr{data_type: "string", name: "Type", value: "Undergrad"},
          %Attr{data_type: "string", name: "EnrolledInCourse", value: "$course"}
        ],
        operations: ["check_out_book"],
        object_attrs: [
          %Attr{data_type: "string", name: "Course", value: "$course"}
        ]
      }
    ]

    # Poison.encode!(policies, pretty: true) |> IO.puts()
  end

  describe "Swarm scenarios" do
    test "selling services, using reputation, and admin policies" do
      _policies = [
        %Policy{
          id: "0",
          user_attrs: [
            %Attr{data_type: "string", name: "Role", value: "AdultFamilyMember"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "SecurityAppliance"}
          ]
        },
        %Policy{
          id: "1",
          user_attrs: [
            %Attr{data_type: "range", name: "Reputation", value: %{min: 4}}
          ],
          operations: ["buy"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "SecurityCamera"},
            %Attr{data_type: "string", name: "Location", value: "Outdoor"}
          ],
          context_attrs: [
            %Attr{data_type: "time_interval", name: "DateTime", value: "* * 8-18 * * *"}
          ]
        },
        %Policy{
          id: "2",
          user_attrs: [
            %Attr{data_type: "string", name: "Id", value: "8a5...934"}
          ],
          operations: ["read"],
          object_attrs: [
            %Attr{data_type: "string", name: "Id", value: "e35...85a"},
            %Attr{data_type: "string", name: "Type", value: "SecurityCamera"}
          ],
          context_attrs: [
            %Attr{data_type: "time_interval", name: "DateTime", value: "10 20-25 12 6 6 2019"}
          ]
        }
      ]
      # |> Policy.simple_encode() |> IO.puts

      _admin_policies = [
        # based on general attributes
        %Policy{
          user_attrs: [
            %Attr{data_type: "range", name: "Role", value: "Admin"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "string", name: "Role", value: "Researcher"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "range", name: "Role", value: "Admin"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "string", name: "Type", value: "SecurityCamera"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "range", name: "Role", value: "Admin"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "range", name: "Reputation", value: %{min: 4}}
          ]
        },
        # or based on policy id
        %Policy{
          user_attrs: [
            %Attr{data_type: "range", name: "Role", value: "Admin"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "string", name: "Id", value: "1"}
          ]
        },
        %Policy{
          user_attrs: [
            %Attr{data_type: "range", name: "Role", value: "Admin"}
          ],
          operations: ["read", "update"],
          object_attrs: [
            %Attr{data_type: "string", name: "Id", value: "2"}
          ]
        }
      ]
    end

    test "policy with tuple attributes" do
      [
        %Policy{
          id: "0",
          user_attrs: [
            ["string", "Role", "AdultFamilyMember"]
          ],
          operations: ["read", "update"],
          object_attrs: [
            ["string", "Type", "SecurityAppliance"]
          ]
        },
        %Policy{
          id: "1",
          user_attrs: [
            ["range", "Reputation", %{min: 4}]
          ],
          operations: ["buy"],
          object_attrs: [
            ["string", "Type", "SecurityCamera"],
            ["string", "Location", "Outdoor"]
          ],
          context_attrs: [
            ["time_interval", "DateTime", "* * 8-18 * * *"]
          ]
        },
        %Policy{
          id: "2",
          user_attrs: [
            ["string", "Id", "8a5...934"]
          ],
          operations: ["read"],
          object_attrs: [
            ["string", "Id", "e35...85a"],
            ["string", "Type", "SecurityCamera"]
          ],
          context_attrs: [
            ["time_interval", "DateTime", "10 20-25 12 6 6 2019"]
          ]
        }
      ]
      # |> Poison.encode!()
      # |> IO.puts()
    end
  end
end
