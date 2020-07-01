defmodule EvaluationTest do
  use ExUnit.Case
  alias ABACthem.{Rule}

  @moduledoc """
  This module is mainly used for experimenting with policies to put in the
  ABAC-them article.
  """

  test "representing the Policy Machine" do
    _policies = [
      %Rule{
        subject: %{"Group" => "Group1"},
        operations: ["write"],
        object: %{"Project" => "Project1"}
      },
      %Rule{
        subject: %{"Group" => "Group2"},
        operations: ["write"],
        object: %{"Project" => "Project2"}
      },
      %Rule{
        subject: %{"Group" => "Group2"},
        operations: ["read", "write"],
        object: %{"Project" => "Gr2-Secret"}
      },
      %Rule{
        subject: %{"Group" => "Division"},
        operations: ["read"],
        object: %{"Project" => "Projects"}
      }
    ]

    # |> PolicyInspect.inspect()
  end

  describe "representing HGABAC" do
    test "case 1" do
      [
        %Rule{
          subject: %{"Type" => "Undergrad"},
          operations: ["check_out_book"],
          object: %{"Type" => "Book", "Restricted" => "False"}
        },
        %Rule{
          subject: %{"Type" => "Undergrad", "EnrolledInCourse" => "CS101"},
          operations: ["check_out_book"],
          object: %{"Course" => "CS101"}
        }
      ]

      # |> PolicyInspect.inspect()
    end

    test "case 2" do
      [
        %Rule{
          subject: %{"Type" => "Gradstudent"},
          operations: ["check_out_book"],
          object: %{"Type" => "Periodical"}
        },
        %Rule{
          subject: %{"Type" => "Gradstudent", "TeachingAssistant" => "CS101"},
          operations: ["check_out_book"],
          object: %{"Course" => "CS101"}
        }
      ]

      # |> PolicyInspect.inspect()
    end

    test "case 3" do
      [
        %Rule{
          subject: %{"Type" => "Faculty"},
          operations: ["check_out_book"],
          object: %{"Type" => "Book"}
        },
        %Rule{
          subject: %{"Type" => "Faculty"},
          operations: ["check_out_book"],
          object: %{"Type" => "Periodical"}
        },
        %Rule{
          subject: %{"Type" => "Faculty"},
          operations: ["check_out_book"],
          object: %{"Type" => "CourseMaterial"}
        },
        %Rule{
          subject: %{"Type" => "Faculty", "Department" => "ComputerScience"},
          operations: ["check_out_book"],
          object: %{"Type" => "ArchivedRecords", "Department" => "ComputerScience"}
        }
      ]
    end

    test "case 4" do
      [
        %Rule{
          subject: %{"Type" => "Staff"},
          operations: ["check_out_book"],
          object: %{"Type" => "*"},
          context: %{"DateTime" => "* * 8-17 * * *", "Weekday" => %{min: 1, max: 5}}
        }
      ]
    end

    test "case 5" do
      [
        %Rule{
          subject: %{"Type" => "Undergrad", "EnrolledInCourse" => "ComputerScience"},
          operations: ["check_out_book"],
          object: %{"Type" => "Periodicals"},
          context: %{"UserIpAddress" => "192.168.*.*"}
        }
      ]
    end
  end

  @tag :skip
  test "HGABAC case 1 >> modified with 'variable'" do
    _policies = [
      %Rule{
        subject: %{"Type" => "Undergrad"},
        operations: ["check_out_book"],
        object: %{"Type" => "Book", "Restricted" => "False"}
      },
      %Rule{
        subject: %{"Type" => "Undergrad", "EnrolledInCourse" => "$course"},
        operations: ["check_out_book"],
        object: %{"Course" => "$course"}
      }
    ]
  end

  describe "Swarm scenarios" do
    test "selling services, using reputation, and admin policies" do
      _policies = [
        %Rule{
          subject: %{"Role" => "AdultFamilyMember"},
          operations: ["read", "update"],
          object: %{"Type" => "SecurityAppliance"}
        },
        %Rule{
          subject: %{"Reputation" => %{min: 4}},
          operations: ["buy"],
          object: %{"Type" => "SecurityCamera", "Location" => "Outdoor"},
          context: %{"DateTime" => "* * 8-18 * * *"}
        },
        %Rule{
          subject: %{"Id" => "8a5...934"},
          operations: ["read"],
          object: %{"Id" => "e35...85a", "Type" => "SecurityCamera"},
          context: %{"DateTime" => "10 20-25 12 6 6 2019"}
        }
      ]

      # |> PolicyInspect.inspect()

      _admin_policies = [
        # based on general attributes
        %Rule{
          subject: %{"Role" => "Admin"},
          operations: ["read", "update"],
          object: %{"Role" => "Researcher"}
        },
        %Rule{
          subject: %{"Role" => "Admin"},
          operations: ["read", "update"],
          object: %{"Type" => "SecurityCamera"}
        },
        %Rule{
          subject: %{"Role" => "Admin"},
          operations: ["read", "update"],
          object: %{"Reputation" => %{min: 4}}
        },
        # or based on Rule id
        %Rule{
          subject: %{"Role" => "Admin"},
          operations: ["read", "update"],
          object: %{"Id" => "1"}
        },
        %Rule{
          subject: %{"Role" => "Admin"},
          operations: ["read", "update"],
          object: %{"Id" => "2"}
        }
      ]
    end
  end
end
