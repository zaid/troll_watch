defmodule TrollWatch.Plug.AuthTokenValidatorTest do
  use ExUnit.Case, async: true

  test "init() returns its opts as-is" do
    assert [foo: :bar] == TrollWatch.Plug.AuthTokenValidator.init(foo: :bar)
  end
end
