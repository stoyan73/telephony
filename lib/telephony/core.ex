defmodule Telephony.Core do
  @moduledoc """
  Create new subscriber and add it to the list
  """
  alias __MODULE__.Constants
  alias __MODULE__.Subscriber

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

  def search_subscriber(subscribers, phone) do
    case Enum.find(subscribers, &(&1.phone_number == phone)) do
      nil -> {:error, "Subscriber not found"}
      subscriber -> subscriber
    end
  end

  def make_a_call(subscribers, phone, time_spent, date) do
    subscribers
    |> search_subscriber(phone)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        subscribers = List.delete(subscribers, subscriber)
        result = Subscriber.make_a_call(subscriber, time_spent, date)
        update_subscribers(subscribers, result)
      end
    end)
  end

  def make_recharge(subscribers, phone, value, date) do
    subscribers
    |> search_subscriber(phone)
    |> then(fn subscriber ->
      if is_nil(subscriber) do
        subscribers
      else
        subscribers = List.delete(subscribers, subscriber)
        result = Subscriber.make_a_recharge(subscriber, value, date)
        update_subscribers(subscribers, result)
      end
    end)
  end

  defp update_subscribers(_subscribers, {:error, msg}) do
    {:error, msg}
  end

  defp update_subscribers(subscribers, result) do
    subscribers ++ [result]
  end
end
