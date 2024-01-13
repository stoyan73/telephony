defmodule Telephony.Server do
  @moduledoc false
  @behaviour GenServer

  alias Telephony.Core

  def init(subscribers) do
    {:ok, subscribers}
  end

  def start_link(server_name, state \\ []) do
    GenServer.start_link(__MODULE__, state, name: server_name)
  end

  def handle_call({:create_subscriber, payload}, _from, subscribers) do
    case Core.create_new_subscriber(subscribers, payload) do
      {:error, _msg} = err -> {:reply, err, subscribers}
      {:ok, new_subscribers} -> {:reply, new_subscribers, new_subscribers}
    end
  end

  def handle_call({:make_recharge, phone, value, date}, _from, subscribers) do
    case Core.make_recharge(subscribers, phone, value, date) do
      {:error, _} = err -> {:reply, err, subscribers}
      new_subscribers -> {:reply, new_subscribers, new_subscribers}
    end
  end

  def handle_call({:make_a_call, phone, time_spent, date}, _from, subscribers) do
    case Core.make_a_call(subscribers, phone, time_spent, date) do
      {:error, _msg} = err -> {:reply, err, subscribers}
      new_subscribers -> {:reply, new_subscribers, new_subscribers}
    end
  end
end
