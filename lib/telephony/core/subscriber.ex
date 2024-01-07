defprotocol Subscriber do
  @moduledoc """
  Defining protocol for Subscriber
  """
  def print_invoice(subscriber_type, calls, start_date, end_date)
  def make_a_call(subscriber_type, time_spent, date)
  def make_a_recharge(subscriber_type, value, date)
end

defmodule Telephony.Core.Subscriber do
  @moduledoc false

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
end
