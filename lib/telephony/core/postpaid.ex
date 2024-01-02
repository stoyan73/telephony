defmodule Telephony.Core.Postpaid do
  alias Telephony.Core.Call
  defstruct spent: 0

  @price_per_minute 0.45

  def make_a_call(subscriber, time_spent, date) do
    subscriber
    |> update_subcriber_type(time_spent)
    |> add_new_call(time_spent, date)
  end

  defp update_subcriber_type(%{subscriber_type: subscriber_type} = subscriber, time_spent) do
    spent = time_spent * @price_per_minute
    subscriber_type = %{subscriber_type | spent: subscriber_type.spent + spent}
    %{subscriber | subscriber_type: subscriber_type}
  end

  defp add_new_call(subscriber, time_spent, date) do
    call = Call.new(time_spent, date)
    %{subscriber | calls: subscriber.calls ++ [call]}
  end
end
