defmodule Telephony.ServerTest do
  use ExUnit.Case, async: true

  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber
  alias Telephony.Server

  require Logger

  setup do
    {:ok, pid} = Server.start_link(:test_telephony)

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

    {:ok, pid2} = Server.start_link(:test_telephony_full, subscribers)
    Logger.debug("setup pid2#{inspect(pid2)}")
    %{pid: pid, pid2: pid2}
  end

  @tag run: true
  test "create a postpaid subscriber", %{pid: pid} do
    Logger.debug("create a postpaid subscriber #{inspect(pid)}")
    # Given
    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :postpaid
    }

    # When
    GenServer.call(pid, {:create_subscriber, payload})
    result = :sys.get_state(pid)
    # Then
    expect =
      [
        %Subscriber{
          full_name: "Stoyan",
          phone_number: "0887229884",
          subscriber_type: %Postpaid{spent: 0}
        }
      ]

    # finall
    assert expect == result
  end

  @tag run: true
  test "create a prepaid subscriber", %{pid: pid} do
    Logger.debug("create a prepaid subscriber #{inspect(pid)}")
    # Given
    payload = %{
      full_name: "Stoyanov",
      phone_number: "0887229885",
      subscriber_type: :prepaid
    }

    # When
    GenServer.call(pid, {:create_subscriber, payload})
    result = :sys.get_state(pid)
    # Then
    expect =
      [
        %Subscriber{
          full_name: "Stoyanov",
          phone_number: "0887229885",
          subscriber_type: %Prepaid{credits: 0, recharges: []}
        }
      ]

    # finall
    assert expect == result
  end

  @tag run: true
  test "make a call prepaid", %{pid2: pid2} do
    # Given
    date = NaiveDateTime.utc_now()
    time_spent = 1
    # When
    GenServer.call(pid2, {:make_a_call, "0887229884", time_spent, date})
    result = :sys.get_state(pid2)
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
end
