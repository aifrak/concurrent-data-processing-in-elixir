good_job = fn ->
  Process.sleep(60_000)
  {:ok, []}
end

bad_job = fn ->
  Process.sleep(5000)
  :error
end

doomed_job = fn ->
  Process.sleep(5000)
  raise "Boom!"
end
