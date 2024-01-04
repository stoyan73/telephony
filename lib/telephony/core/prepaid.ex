defmodule Telephony.Core.Prepaid do
  @moduledoc false
  alias Telephony.Core.Call
  alias Telephony.Core.Constants
  alias Telephony.Core.Recharge

  defstruct credits: 0, recharges: []

  @price_per_minute 1.45

  def make_a_call(subscriber, time_spent, date) do
    if is_subscriber_has_credits(subscriber, time_spent) do
      subscriber
      |> update_subcriber_type(time_spent)
      |> add_new_call(time_spent, date)
    else
      {:error, Constants.error_not_enough_credits()}
    end
  end

  defp is_subscriber_has_credits(%{subscriber_type: subscriber_type}, time_spent) do
    subscriber_type.credits >= time_spent * @price_per_minute
  end

  defp update_subcriber_type(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    credit_spent = time_spent * @price_per_minute

    subscriber_type = %{subscriber_type | credits: subscriber_type.credits - credit_spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end

  # -------------------
  def make_recharge(subscriber, value, date) do
    update_credits(subscriber, value, date)
  end

  defp update_credits(%{subscriber_type: subscriber_type} = subscriber, value, date) do
    rechardge = Recharge.new(value, date)

    subscriber_type = %{
      subscriber_type
      | recharges: subscriber_type.recharges ++ [rechardge],
        credits: subscriber_type.credits + value
    }

    %{subscriber | subscriber_type: subscriber_type}
  end
end
