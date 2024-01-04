defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Invoice
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge
  alias Telephony.Core.Subscriber

  setup do
    subscriber =
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }

    %{subscriber: subscriber}
  end

  test "make a call", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 2
    # When
    result = Prepaid.make_a_call(subscriber, time_spent, date)
    IO.inspect(result)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Prepaid{credits: 7.1, recharges: []},
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

  test "not enough credits", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Prepaid.make_a_call(subscriber, time_spent, date)
    IO.inspect(result)
    # Then
    expect = {:error, Constants.error_not_enough_credits()}
    # finall
    assert expect == result
  end

  test "make a recharge", %{subscriber: subscriber} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    value = 100
    # When
    result = Prepaid.make_recharge(subscriber, value, date)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Prepaid{
        credits: 110,
        recharges: [
          %Recharge{value: value, date: date}
        ]
      }
    }

    # finall
    assert expect == result
  end

  test "print invoice" do
    # given
    start_date = ~D[2023-12-15]
    end_date = ~D[2024-01-15]

    subscriber = %Subscriber{
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

    result = Invoice.print(subscriber, start_date, end_date)

    expect = %Invoice{
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
      total_credis: 150,
      remaining_credits: 93.45
    }

    # finall
    assert expect == result
  end
end
