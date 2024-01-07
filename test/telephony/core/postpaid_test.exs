defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid

  setup do
    subscriber =
      %Telephony.Core.Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Postpaid{spent: 0}
      }

    %{subscriber: subscriber}
  end

  @tag run: true
  test "make a postpaid call", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Subscriber.make_a_call(subscriber.subscriber_type, time_spent, date)

    # Then
    expect =
      {%Telephony.Core.Postpaid{spent: 4.5}, %Telephony.Core.Call{time_spent: 10, date: date}}

    # finall
    assert expect == result
  end

  @tag run: true
  test "make a recharge" do
    # Given
    date = NaiveDateTime.utc_now()
    subscriber_type = %Postpaid{spent: 10}
    value = 100
    # When
    result = Subscriber.make_a_recharge(subscriber_type, value, date)
    # Then
    expect = {:error, Constants.error_prepaid_recharge()}

    # finall
    assert expect == result
  end

  @tag run: true
  test "print postpaid" do
    # Given
    start_date = ~D[2023-12-15]
    end_date = ~D[2024-01-15]
    # im minutes

    subscriber = %Telephony.Core.Subscriber{
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
    result = Subscriber.print_invoice(subscriber_type, calls, start_date, end_date)
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
