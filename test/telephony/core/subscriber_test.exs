defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Recharge
  alias Telephony.Core.Subscriber

  setup do
    postpaid =
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Postpaid{spent: 10}
      }

    prepaid =
      %Subscriber{
        full_name: "Stoyan2",
        phone_number: "0887229885",
        subscriber_type: %Prepaid{credits: 10, recharges: []}
      }

    %{postpaid: postpaid, prepaid: prepaid}
  end

  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :prepaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Prepaid{credits: 0, recharges: []}
    }

    # finall
    assert expect == result
  end

  test "create a postpaid subscriber" do
    # Given
    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :postpaid
    }

    # When
    result = Subscriber.new(payload)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 0}
    }

    # finall
    assert expect == result
  end
  @tag run: true
  test "make a postpaid call", %{postpaid: postpaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Subscriber.make_a_call(postpaid, time_spent, date)

    # Then
    expect = %Telephony.Core.Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 14.5},
      calls: [
        %Call{time_spent: 10, date: date}
      ]
    }

    # finall
    assert expect == result
  end

  test "make a prepaid call", %{prepaid: prepaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 1
    # When
    result = Subscriber.make_a_call(prepaid, time_spent, date)

    # Then
    expect = %Telephony.Core.Subscriber{
      full_name: "Stoyan2",
      phone_number: "0887229885",
      subscriber_type: %Telephony.Core.Prepaid{
        credits: 8.55,
        recharges: []
      },
      calls: [
        %Call{
          date: date,
          time_spent: 1
        }
      ]
    }

    # finall
    assert expect == result
  end

  test "make a prepaid call without credits", %{prepaid: prepaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Subscriber.make_a_call(prepaid, time_spent, date)
    # Then
    expect = {:error, Constants.error_not_enough_credits()}
    # finall
    assert expect == result
  end

  test "make a recharge prepaid", %{prepaid: prepaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    value = 100
    # When
    result = Subscriber.make_a_recharge(prepaid, value, date)
    # Then
    expect = %Subscriber{
      subscriber_type: %Telephony.Core.Prepaid{
        credits: 110,
        recharges: [
          %Recharge{
            date: date,
            value: 100
          }
        ]
      },
      calls: [],
      full_name: "Stoyan2",
      phone_number: "0887229885"
    }

    # finall
    assert expect == result
  end

  test "print prepaid invoice" do
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

    result = Subscriber.print_invoice(subscriber, start_date, end_date)

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
