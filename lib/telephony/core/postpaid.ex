defmodule Telephony.Core.Postpaid do
  @moduledoc false
  alias Telephony.Core.Call
  alias Telephony.Core.Constants

  defstruct spent: 0

  defimpl Subscriber, for: __MODULE__ do
    @price_per_minute 0.45
    def print_invoice(_subdctiber_type, calls, start_date, end_date) do
      calls =
        Enum.reduce(calls, [], fn call, acc ->
          if Date.diff(start_date, call.date) <= 0 and Date.diff(call.date, end_date) <= 0 do
            value = call.time_spent * @price_per_minute

            call = %{date: call.date, time_spent: call.time_spent, value_spent: value}
            acc ++ [call]
          else
            acc
          end
        end)

      total_value = Enum.reduce(calls, 0, fn call, acc -> acc + call.value_spent end)

      %{
        calls: calls,
        total_value: total_value
      }
    end

    def make_a_call(subscriber_type, time_spent, date) do
      subscriber_type
      |> update_subcriber_type(time_spent)
      |> add_new_call(time_spent, date)
    end

    def make_a_recharge(_, _, _) do
      {:error, Constants.error_prepaid_recharge()}
    end

    defp update_subcriber_type(subscriber_type, time_spent) do
      spent = time_spent * @price_per_minute
      %{subscriber_type | spent: subscriber_type.spent + spent}
    end

    defp add_new_call(subscriber_type, time_spent, date) do
      call = Call.new(time_spent, date)
      {subscriber_type, call}
    end
  end
end
