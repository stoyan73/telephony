defmodule Telephony.Core.Invoice do
  alias Telephony.Core.{Prepaid, Postpaid}
  defstruct calls: [], recharges: [], total_value: 0, total_credis: 0, remaining_credits: 0

  def print(%{subscriber_type: %Prepaid{}} = subscriber, start_date, end_date) do
  end

  def print(%{subscriber_type: %Postpaid{}} = subscriber, start_date, end_date) do
  end
end
