defmodule Emqttd.Hooks do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute __MODULE__, :emqttd_hooks, [
        accumulate: true,
        persist: false
      ]
      import unquote(__MODULE__), only: [defhook: 2]
      @before_compile unquote(__MODULE__)

      def before_load do end
      def after_load do end
      def before_unload do end
      def after_unload do end

      defoverridable [
        before_load: 0,
        after_load: 0,
        before_unload: 0,
        after_unload: 0
      ]
    end
  end

  defmacro defhook(definition = {name, _ctx, _args}, do: content) do
    valid_hooks = [
      :"client.connected",
      :"client.subscribe",
      :"client.subscribe.after",
      :"client.unsubscribe",
      :"message.publish",
      :"message.acked",
      :"client.disconnected"
    ]
    hook = name
            |> Atom.to_string
            |> String.replace("_", ".")
            |> String.to_atom
    cond do
      hook in valid_hooks -> :ok
      :otherwise -> raise "Invalid hook #{name}"
    end
    quote do
      @emqttd_hooks {unquote(hook),unquote(name)}
      def unquote(definition) do
        unquote(content)
      end
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def load(opts \\ []) do
        before_load
        Enum.each @emqttd_hooks, fn
          {hook,func_name} ->
            # Don't ask me why this weird invocation. I copied it from emqttd sample plugin.
            # XXX: Find out the reason for repetition.
            :emqttd_broker.hook hook, {__MODULE__, func_name}, {__MODULE__, func_name, [opts]}
        end
        after_load
      end
      def unload(opts \\ []) do
        before_unload
        Enum.each @emqttd_hooks, fn
          {hook,func_name} ->
            :emqttd_broker.unhook hook, {__MODULE__, func_name}
        end
        after_unload
      end
    end
  end
end
