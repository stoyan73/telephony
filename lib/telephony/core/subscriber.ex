defmodule Telephony.Core.Subscriber do
  alias Telephony.Core.{Constants, Prepaid, Postpaid}

  defstruct full_name: nil, phone_number: nil, subscriber_type: nil, calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_a_call(%{subscriber_type: %Postpaid{}} = subscriber, time_spent, date) do
    # when subscriber_type.__struct__ == Postpaid do
    IO.inspect("Postpaid call")
    Postpaid.make_a_call(subscriber, time_spent, date)
  end

  def make_a_call(
        %{subscriber_type: %Prepaid{}} = subscriber,
        time_spent,
        date
      ) do
    # when subscriber_type.__struct__ == Prepaid do
    IO.inspect("Prepaid call")
    Prepaid.make_a_call(subscriber, time_spent, date)
  end

  def make_recharge(
        %{subscriber_type: %Prepaid{}} = subscriber,
        value,
        date
      ) do
    # when subscriber_type.__struct__ == Prepaid do
    IO.inspect("Prepaid make recharge")
    Prepaid.make_recharge(subscriber, value, date)
  end

  def make_recharge(_, _, _) do
    IO.inspect("Not a prepaid subscriber make recharge")
    {:error, Constants.error_prepaid_recharge()}
  end
end
