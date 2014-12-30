defmodule Comeonin.Bcrypt do
  @moduledoc """
  Module to handle Bcrypt authentication.
  """

  alias Comeonin.Tools

  @on_load {:init, 0}
  @log_rounds 12

  def init do
    path = :filename.join(:code.priv_dir(:comeonin), 'bcrypt_nif')
    :ok = :erlang.load_nif(path, 0)
  end

  @doc """
  Generate a salt for use with the `hashpw`, `hashpass` and
  `hashpwsalt` functions.

  The log_rounds parameter determines the computational complexity
  of the hashing. Its default is 12, the minimum is 4, and the maximum
  is 31. If less than 4 is input, 4 will be used, and if more than
  31 is input, 31 will be used.
  """
  def gen_salt(log_rounds) when is_integer(log_rounds) do
    :crypto.rand_bytes(16) |> encode_salt(log_rounds)
  end
  def gen_salt(_), do: gen_salt(@log_rounds)
  def gen_salt, do: gen_salt(@log_rounds)

  defp encode_salt(_rand_num, _log_rounds) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password using Bcrypt.
  """
  def hashpass(password, salt) when is_binary(salt) do
    if String.length(salt) == 29 do
      salt = String.to_char_list(salt)
      hashpass(password, salt)
    else
      raise ArgumentError, message: "The salt is the wrong length."
    end
  end
  def hashpass(password, salt) when is_binary(password) do
    String.to_char_list(password) |> hashpw(salt) |> :erlang.list_to_binary
  end
  def hashpass(_password, _salt) do
    raise ArgumentError, message: "Wrong type. The password needs to be a string."
  end
  defp hashpw(_password, _salt) do
    exit(:nif_library_not_loaded)
  end

  @doc """
  Hash the password with a salt which is randomly generated.
  """
  def hashpwsalt(password) do
    salt = gen_salt(@log_rounds)
    hashpass(password, salt)
  end

  @doc """
  Check the password.

  The check is performed in constant time to avoid timing attacks.

  Perform a dummy check for a user that does not exist.
  This always returns false. The reason for implementing this check is
  in order to make user enumeration by timing responses more difficult.
  """
  def checkpw(password, hash) do
    password = String.to_char_list(password)
    hash = String.to_char_list(hash)
    hashpw(password, hash) |> Tools.secure_check(hash)
  end
  def checkpw do
    checkpw("", "$2a$05$CCCCCCCCCCCCCCCCCCCCC.7uG0VCzI2bS7j6ymqJi9CdcdxiRTWNy")
    false
  end
end