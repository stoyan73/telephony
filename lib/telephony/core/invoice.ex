defmodule Telephony.Core.Invoice do
  @moduledoc false
  defstruct calls: [], recharges: [], total_value: 0, total_credis: 0, remaining_credits: 0
end

defprotocol Invoice do
  def print(subscriber, start_date, end_date)
end
