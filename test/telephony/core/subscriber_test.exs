defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case
  alias Telephony.Core.{Call, Constants, Postpaid, Prepaid, Recharge, Subscriber}

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

  @tag run: false
  test "create a subscriber" do
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

  @tag run: true
  test "make a postpaid call", %{postpaid: postpaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 10
    # When
    result = Subscriber.make_a_call(postpaid, time_spent, date)
    IO.inspect(result)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 14.5},
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
  test "make a prepaid call", %{prepaid: prepaid} do
    # Given
    date = NaiveDateTime.utc_now()
    # im minutes
    time_spent = 2
    # When
    result = Subscriber.make_a_call(prepaid, time_spent, date)

    # Then
    expect = %Subscriber{
      full_name: "Stoyan2",
      phone_number: "0887229885",
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

  @tag run: true
  test "make a recharge", %{prepaid: prepaid} do
    # Given
    date = NaiveDateTime.utc_now()

    value = 100
    # When
    result = Subscriber.make_recharge(prepaid, value, date)
    IO.inspect(result)
    # Then
    expect = %Subscriber{
      full_name: "Stoyan2",
      phone_number: "0887229885",
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

  @tag run: true
  test "make recharge error ", %{postpaid: postpaid} do
    # Given
    date = NaiveDateTime.utc_now()

    value = 100
    # When
    result = Subscriber.make_recharge(postpaid, value, date)

    # Then
    expect = {:error, Constants.error_prepaid_recharge()}

    # finall
    assert expect == result
  end

  @tag run: true
  test "not enough credits", %{prepaid: prepaid} do
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
end
