defmodule Telephony.Core.PostpaidTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Postpaid, Subscriber}

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
    IO.inspect(result)
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
end
