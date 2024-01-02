defmodule Telephony.Core.Recharge do
  defstruct value: 0, date: nil

  def new(value, date) do
    %__MODULE__{value: value, date: date}
  end

end
