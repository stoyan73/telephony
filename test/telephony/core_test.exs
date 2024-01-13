defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.Core
  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Prepaid{credits: 10, recharges: []},
        calls: []
      },
      %Subscriber{
        full_name: "Stoyanov",
        phone_number: "0887229885",
        subscriber_type: %Postpaid{spent: 0},
        calls: []
      }
    ]

    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

  @tag run: true
  test "create a postpaid subscriber" do
    # Given
    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :postpaid
    }

    subscribers = []

    # When
    result = Core.create_new_subscriber(subscribers, payload)
    # Then
    expect =
      {:ok,
       [
         %Subscriber{
           full_name: "Stoyan",
           phone_number: "0887229884",
           subscriber_type: %Postpaid{spent: 0}
         }
       ]}

    # finall
    assert expect == result
  end

  @tag run: true
  test "create a prepaid subscriber" do
    # Given
    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :prepaid
    }

    subscribers = []

    # When
    result = Core.create_new_subscriber(subscribers, payload)
    # Then
    expect =
      {:ok,
       [
         %Subscriber{
           full_name: "Stoyan",
           phone_number: "0887229884",
           subscriber_type: %Prepaid{credits: 0, recharges: []}
         }
       ]}

    # finall
    assert expect == result
  end

  @tag run: true
  test "create a one more subscriber", %{subscribers: subscribers} do
    # Given
    payload = %{
      full_name: "StoyanovS",
      phone_number: "0887229886",
      subscriber_type: :prepaid
    }

    # When
    result = Core.create_new_subscriber(subscribers, payload)
    # Then
    expect =
      {:ok,
       [
         %Subscriber{
           full_name: "Stoyan",
           phone_number: "0887229884",
           subscriber_type: %Prepaid{credits: 10, recharges: []}
         },
         %Subscriber{
           full_name: "Stoyanov",
           phone_number: "0887229885",
           subscriber_type: %Postpaid{spent: 0},
           calls: []
         },
         %Subscriber{
           full_name: "StoyanovS",
           phone_number: "0887229886",
           subscriber_type: %Prepaid{credits: 0, recharges: []}
         }
       ]}

    # finall
    assert expect == result
  end

  @tag run: true
  test "phone exist error", %{subscribers: subscribers, payload: payload} do
    # When
    result = Core.create_new_subscriber(subscribers, payload)
    # Then
    expect = {:error, Constants.error_number_exist(payload.phone_number)}

    assert expect == result
  end

  @tag run: true
  test "subscriber type not valid error" do
    # Given
    payload = %{
      full_name: "Stoyanov",
      phone_number: "0887229885",
      subscriber_type: :prepaids
    }

    # When
    result = Core.create_new_subscriber([], payload)
    # Then
    expect = {:error, Constants.error_subscriber_type_not_valid(payload.subscriber_type)}

    assert expect == result
  end

  @tag run: true
  test "subscriber not found", %{subscribers: subscribers} do
    # Given
    # When
    result = Core.search_subscriber(subscribers, "123")
    # Then
    expect = {:error, "Subscriber not found"}

    assert expect == result
  end

  @tag run: true
  test "find subscriber", %{subscribers: subscribers} do
    # Given
    # When
    result = Core.search_subscriber(subscribers, "0887229884")
    # Then
    expect = %Telephony.Core.Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Prepaid{credits: 10, recharges: []},
      calls: []
    }

    assert expect == result
  end

  @tag run: true
  test "make a call prepaid", %{subscribers: subscribers} do
    # Given
    date = NaiveDateTime.utc_now()
    time_spent = 1
    # When
    result = Core.make_a_call(subscribers, "0887229884", time_spent, date)

    # Then
    expect = [
      %Telephony.Core.Subscriber{
        full_name: "Stoyanov",
        phone_number: "0887229885",
        subscriber_type: %Telephony.Core.Postpaid{spent: 0},
        calls: []
      },
      %Telephony.Core.Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Prepaid{credits: 8.55, recharges: []},
        calls: [
          %Call{time_spent: 1, date: date}
        ]
      }
    ]

    assert expect == result
  end

  @tag run: true
  test "make a call postpaid", %{subscribers: subscribers} do
    # Given
    date = NaiveDateTime.utc_now()
    time_spent = 10
    # When
    result = Core.make_a_call(subscribers, "0887229885", time_spent, date)

    # Then
    expect = [
      %Telephony.Core.Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Telephony.Core.Prepaid{credits: 10, recharges: []},
        calls: []
      },
      %Telephony.Core.Subscriber{
        full_name: "Stoyanov",
        phone_number: "0887229885",
        subscriber_type: %Telephony.Core.Postpaid{spent: 4.5},
        calls: [
          %Telephony.Core.Call{time_spent: 10, date: date}
        ]
      }
    ]

    assert expect == result
  end

  @tag run: true
  test "make recharge prepaid", %{subscribers: subscribers} do
    # Given
    date = NaiveDateTime.utc_now()
    value = 100
    # When
    result = Core.make_recharge(subscribers, "0887229884", value, date)
    # Then
    expect = [
      %Subscriber{
        full_name: "Stoyanov",
        phone_number: "0887229885",
        subscriber_type: %Telephony.Core.Postpaid{spent: 0},
        calls: []
      },
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Telephony.Core.Prepaid{
          credits: 110,
          recharges: [%Telephony.Core.Recharge{value: 100, date: date}]
        },
        calls: []
      }
    ]

    assert expect == result
  end

  @tag run: true
  test "make recharge postpaid", %{subscribers: subscribers} do
    # Given
    date = NaiveDateTime.utc_now()
    value = 100
    # When
    result = Core.make_recharge(subscribers, "0887229885", value, date)
    # Then
    expect = {:error, "Only prepaid subscriber can make recharge!"}

    assert expect == result
  end
end
