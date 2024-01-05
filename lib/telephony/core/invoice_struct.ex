defmodule Telephony.Core.InvoiceStruct do
  @moduledoc false
  defstruct calls: [], recharges: [], total_value: 0, total_credis: 0, remaining_credits: 0
end
