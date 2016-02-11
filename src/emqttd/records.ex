defmodule Emqttd.Records do
  @moduledoc """
  This module defines a single macro, `__using__`, which is automatically invoked
  when the statement `use Emqttd.Records` is encountered. It looks up the current
  `emqttd.hrl` that corresponds to the exact emqttd version we are building against,
  extracts the records `mqtt_client` and `mqtt_message` defined in it and defines
  macros by the same name.

  For instance, after `use`ing this module, `mqtt_client` can be matched as follows:

      mqtt_client(username: name) = client

  Any key mismatches will result in a compilation error.
  """

  @emqttd_hrl Path.expand("../../include/emqttd.hrl", File.cwd!)

  @doc """
  Inject the mqtt_client record definition from emqttd source
  """
  defmacro __using__(_opts) do
    quote do
      require Record
      Record.defrecordp :mqtt_client, Record.extract(:mqtt_client, from: unquote(@emqttd_hrl))
      @type mqtt_client :: record(:mqtt_client)

      Record.defrecordp :mqtt_message, Record.extract(:mqtt_message, from: unquote(@emqttd_hrl))
      @type mqtt_message :: record(:mqtt_message)
    end
  end
end
