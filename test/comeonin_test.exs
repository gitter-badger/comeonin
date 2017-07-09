defmodule ComeoninTest do
  use ExUnit.Case, async: true

  def hash_check_password(password, wrong1, wrong2, wrong3) do
    for crypto <- [Argon2, Bcrypt, Pbkdf2] do
      hash = Comeonin.create_hash(password, crypto)
      user = %{id: 2, name: "fred", password_hash: hash}
      assert Comeonin.check_pass(user, password, crypto) == {:ok, user}
      assert Comeonin.check_pass(nil, password, crypto) == {:error, "invalid user-identifier"}
      assert Comeonin.check_pass(user, wrong1, crypto) == {:error, "invalid password"}
      assert Comeonin.check_pass(user, wrong2, crypto) == {:error, "invalid password"}
      assert Comeonin.check_pass(user, wrong3, crypto) == {:error, "invalid password"}
    end
  end

  test "hashing and checking passwords" do
    hash_check_password("password", "passwor", "passwords", "pasword")
    hash_check_password("hard2guess", "ha rd2guess", "had2guess", "hardtoguess")
  end

  test "hashing and checking passwords with characters from the extended ascii set" do
    hash_check_password("aáåäeéêëoôö", "aáåäeéêëoö", "aáåeéêëoôö", "aáå äeéêëoôö")
    hash_check_password("aáåä eéêëoôö", "aáåä eéê ëoö", "a áåeé êëoôö", "aáå äeéêëoôö")
  end

  test "hashing and checking passwords with non-ascii characters" do
    hash_check_password("Сколько лет, сколько зим", "Сколько лет,сколько зим",
    "Сколько лет сколько зим", "Сколько лет, сколько")
    hash_check_password("สวัสดีครับ", "สวัดีครับ", "สวัสสดีครับ", "วัสดีครับ")
  end

  test "hashing and checking passwords with mixed characters" do
    hash_check_password("Я❤três☕ où☔", "Я❤tres☕ où☔", "Я❤três☕où☔", "Я❤três où☔")
  end

end
