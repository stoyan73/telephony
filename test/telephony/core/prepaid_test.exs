defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge

  setup do
    subscriber =
      %Telephony.Core.Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }

    %{subscriber: subscriber}
  end

  @tag run: true
  test "make a prepaid call", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 2
    # When

    result = Subscriber.make_a_call(subscriber.subscriber_type, time_spent, date)

    # Then
    expect = {%Prepaid{credits: 7.1, recharges: []}, %Call{time_spent: 2, date: date}}

    # finall
    assert expect == result
  end

  @tag run: true
  test "not enough credits", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    subscriber_type = subscriber.subscriber_type
    result = Subscriber.make_a_call(subscriber_type, time_spent, date)
    # Then
    expect = {:error, Constants.error_not_enough_credits()}
    # finall
    assert expect == result
  end

  @tag run: true
  test "make a recharge", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    value = 100
    # When
    result = Subscriber.make_a_recharge(subscriber.subscriber_type, value, date)
    # Then
    expect = %{
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{
            date: date,
            value: 100
          }
        ]
      }
    }

    # finall
    assert expect == result
  end

  @tag run: true
  test "print invoice" do
    # given
    start_date = ~D[2023-12-15]
    end_date = ~D[2024-01-15]

    subscriber = %Telephony.Core.Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Prepaid{
        credits: 93.45,
        recharges: [
          %Recharge{value: 50, date: ~D[2023-12-16]},
          %Recharge{value: 50, date: ~D[2023-12-25]},
          %Recharge{value: 50, date: ~D[2023-12-30]}
        ]
      },
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
    result = Subscriber.print_invoice(subscriber_type, calls, start_date, end_date)

    expect = %{
      calls: [
        %{
          time_spent: 2,
          value_spent: 2.9,
          date: ~D[2023-12-16]
        },
        %{
          time_spent: 1,
          value_spent: 1.45,
          date: ~D[2023-12-16]
        },
        %{
          time_spent: 1,
          value_spent: 1.45,
          date: ~D[2023-12-17]
        },
        %{
          time_spent: 5,
          value_spent: 7.25,
          date: ~D[2023-12-18]
        },
        %{
          time_spent: 20,
          value_spent: 29.0,
          date: ~D[2023-12-19]
        },
        %{
          time_spent: 10,
          value_spent: 14.50,
          date: ~D[2023-12-29]
        }
      ],
      recharges: [
        %Recharge{value: 50, date: ~D[2023-12-16]},
        %Recharge{value: 50, date: ~D[2023-12-25]},
        %Recharge{value: 50, date: ~D[2023-12-30]}
      ],
      total_value: 56.55,
      total_credits: 150,
      remaining_credits: 93.45
    }

    # finall
    assert expect == result
  end
end
