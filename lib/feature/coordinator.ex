defmodule ExOwm.Feature.Coordinator do
  use GenServer
  alias ExOwm.Feature.Worker

  ## Client API
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options ++ [name: :exowm_coordinator])
  end

  def get_state do
    GenServer.call(:exowm_coordinator, {:get_state})
  end

  def set_location_weather(location_weather) do
    GenServer.cast(:exowm_coordinator, {:set_location_weather, location_weather})
  end

  def start_workers(locations) do
    # {:reply, results, _state} = GenServer.call(:exowm_coordinator, {:start_workers, locations})
    GenServer.call(:exowm_coordinator, {:start_workers, locations})
    # results
  end

  ## Server implementation
  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:get_state}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:start_workers, locations}, _from, _state) do
    worker_tasks = Enum.map(locations, fn(location) -> Task.async(Worker, :run, [location]) end)
    results = Enum.map(worker_tasks, fn(task) -> Task.await(task) end)
    {:reply, results, results}
  end

  def handle_cast({:set_location_weather, location_weather}, state) do
    {:noreply, [location_weather | state]}
  end

end
