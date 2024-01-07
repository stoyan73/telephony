defmodule Telephony.Core.Constants do
  @moduledoc false
  def error_number_exist(number), do: "Phone number '#{number}' already exixt!"
  def error_subscriber_type_not_valid(type), do: "Subscriber type  '#{type}' is not valid!"
  def error_not_enough_credits, do: "Subsciber don't have enough credits!"
  def error_prepaid_recharge, do: "Only prepaid subscriber can make recharge!"
end
