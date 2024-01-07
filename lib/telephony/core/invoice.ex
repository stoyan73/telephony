defprotocol Invoice do
  def print(subscriber_type, calls, start_date, end_date)
end
