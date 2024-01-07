defmodule Telephony.Core.SubscriberTest do
  use ExUnit.Case

  # alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid
  alias Telephony.Core.Subscriber
  # alias Telephony.Core.Recharge

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

  @tag run: true
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

  @tag run: true
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
    expect = %Telephony.Core.Subscriber{
      full_name: "Stoyan",
      phone_number: "0887229884",
      subscriber_type: %Postpaid{spent: 0}
    }

    # finall
    assert expect == result
  end
end
