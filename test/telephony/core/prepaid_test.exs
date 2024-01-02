defmodule Telephony.Core.PrepaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Constants, Prepaid, Recharge, Subscriber}

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
    IO.inspect(result)
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
end
