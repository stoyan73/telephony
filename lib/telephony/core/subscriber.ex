defprotocol Subscriber do
  @moduledoc """
  Defining protocol for Subscriber
  """
  def print_invoice(subscriber_type, calls, start_date, end_date)
  def make_a_call(subscriber_type, time_spent, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false
  alias Telephony.Core.Constants
  alias Telephony.Core.Postpaid
  alias Telephony.Core.Prepaid

  defstruct full_name: nil, phone_number: nil, subscriber_type: nil, calls: []

  def new(%{subscriber_type: :prepaid} = payload) do
    payload = %{payload | subscriber_type: %Prepaid{}}
    struct(__MODULE__, payload)
  end

  def new(%{subscriber_type: :postpaid} = payload) do
    payload = %{payload | subscriber_type: %Postpaid{}}
    struct(__MODULE__, payload)
  end

  def make_recharge(%{subscriber_type: %Prepaid{}} = subscriber, value, date) do
    # when subscriber_type.__struct__ == Prepaid do

    Prepaid.make_recharge(subscriber, value, date)
  end

  def make_recharge(_, _, _) do
    {:error, Constants.error_prepaid_recharge()}
  end
end
