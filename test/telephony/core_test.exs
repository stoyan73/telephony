defmodule Telephony.CoreTest do
  use ExUnit.Case

  alias Telephony.Core
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber

  setup do
    subscribers = [
      %Subscriber{
        full_name: "Stoyan",
        phone_number: "0887229884",
        subscriber_type: %Prepaid{credits: 0, recharges: []}
      }
    ]

    payload = %{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: :prepaid
    }

    %{subscribers: subscribers, payload: payload}
  end

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

  test "create a one more subscriber", %{subscribers: subscribers} do
    # Given
    payload = %{
      full_name: "Stoyanov",
      phone_number: "0887229885",
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
           subscriber_type: %Prepaid{credits: 0, recharges: []}
         },
         %Subscriber{
           full_name: "Stoyanov",
           phone_number: "0887229885",
           subscriber_type: %Prepaid{credits: 0, recharges: []}
         }
       ]}

    # finall
    assert expect == result
  end

  test "phone exist error", %{subscribers: subscribers, payload: payload} do
    # When
    result = Core.create_new_subscriber(subscribers, payload)
    # Then
    expect = {:error, Constants.error_number_exist(payload.phone_number)}

    assert expect == result
  end

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
end
