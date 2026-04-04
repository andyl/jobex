defmodule JobexCore.SchedulerTest do
  use ExUnit.Case

  alias JobexCore.Scheduler

  setup do
    tmp_dir = Path.join(System.tmp_dir!(), "jobex_sched_test_#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp_dir)
    System.put_env("JOBEX_CSV_DIR", tmp_dir)

    on_exit(fn ->
      Scheduler.delete_all_jobs()
      File.rm_rf!(tmp_dir)
      System.delete_env("JOBEX_CSV_DIR")
    end)

    %{tmp_dir: tmp_dir}
  end

  describe "load_file/1" do
    test "loads valid jobs from CSV", %{tmp_dir: tmp_dir} do
      content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n*/5 * * * *,parallel,check,uptime\n"
      File.write!(Path.join(tmp_dir, "valid.csv"), content)

      Scheduler.load_file("valid.csv")

      jobs = Scheduler.jobs()
      assert length(jobs) == 2
    end

    test "skips rows with empty schedule without crashing", %{tmp_dir: tmp_dir} do
      content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\n,serial,bad,broken\n*/5 * * * *,parallel,check,uptime\n"
      File.write!(Path.join(tmp_dir, "with_empty.csv"), content)

      Scheduler.load_file("with_empty.csv")

      jobs = Scheduler.jobs()
      assert length(jobs) == 2
    end

    test "skips rows with invalid cron expression without crashing", %{tmp_dir: tmp_dir} do
      content = "SCHEDULE,QUEUE,TYPE,COMMAND\n* * * * *,serial,test,date\nnot_a_cron,serial,bad,broken\n"
      File.write!(Path.join(tmp_dir, "with_invalid.csv"), content)

      Scheduler.load_file("with_invalid.csv")

      jobs = Scheduler.jobs()
      assert length(jobs) == 1
    end
  end
end
