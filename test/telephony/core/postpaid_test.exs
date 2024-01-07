defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Subscriber

  setup do
    subscriber =
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Postpaid{spent: 0}
      }

    %{subscriber: subscriber}
  end

  @tag run: false
  test "make a call", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Postpaid.make_a_call(subscriber, time_spent, date)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 4.5},
      calls: [
        %Call{
          time_spent: time_spent,
          date: date
        }
      ]
    }

    # finall
    assert expect == result
  end

  @tag run: true
  test "print postpaid" do
    # Given
    start_date = ~D[2023-12-15]
    end_date = ~D[2024-01-15]
    # im minutes

    subscriber = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 56.55},
      calls: [
        %Call{
          time_spent: 2,
          date: ~D[2023-12-16]
        },
        %Call{
          time_spent: 1,
          date: ~D[2023-12-16]
        },
        %Call{
          time_spent: 1,
          date: ~D[2023-12-17]
        },
        %Call{
          time_spent: 5,
          date: ~D[2023-12-18]
        },
        %Call{
          time_spent: 20,
          date: ~D[2023-12-19]
        },
        %Call{
          time_spent: 10,
          date: ~D[2023-12-29]
        }
      ]
    }

    subscriber_type = subscriber.subscriber_type
    calls = subscriber.calls
    # When
    result = Invoice.print(subscriber_type, calls, start_date, end_date)
    # Then
    expect = %{
      calls: [
        %{date: ~D[2023-12-16], time_spent: 2, value_spent: 0.9},
        %{
          date: ~D[2023-12-16],
          time_spent: 1,
          value_spent: 0.45
        },
        %{
          date: ~D[2023-12-17],
          time_spent: 1,
          value_spent: 0.45
        },
        %{
          date: ~D[2023-12-18],
          time_spent: 5,
          value_spent: 2.25
        },
        %{
          date: ~D[2023-12-19],
          time_spent: 20,
          value_spent: 9.0
        },
        %{
          date: ~D[2023-12-29],
          time_spent: 10,
          value_spent: 4.5
        }
      ],
      total_value: 17.55
    }

    # finall
    assert expect == result
  end
end
