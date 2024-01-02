defmodule Telephony.Core do
  alias __MODULE__.Subscriber
  alias __MODULE__.Constants

  @moduledoc """
  Create new subscriber and add it to the list
  """
  @spec create_new_subscriber(list(Subscriber.__struct__()), map()) ::
          {:ok, list(Subscriber.__struct__())} | :error
  def create_new_subscriber(subscribers, %{subscriber_type: subscriber_type} = payload)
      when subscriber_type in [:prepaid, :postpaid] do
    case Enum.find(subscribers, fn subscriber ->
           subscriber.phone_number == payload.phone_number
         end) do
      nil ->
        {:ok, subscribers ++ [Subscriber.new(payload)]}

      subscriber ->
        {:error, Constants.error_number_exist(subscriber.phone_number)}
    end
  end

  def create_new_subscriber(_subscribers, payload) do
    {:error, Constants.error_subscriber_type_not_valid(payload.subscriber_type)}
  end
end
