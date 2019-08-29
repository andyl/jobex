# Import plugins from `rel/plugins`.  
# Use by adding `plugin MyPlugin` to an
# environment or release.
#
~w(rel plugins *.exs)
|> Path.join()
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
    # default release built by `mix distillery.release`
    default_release: :default,
    # default environment used by `mix distillery.release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/config/distillery.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set dev_mode: true
  set include_erts: false
  set cookie: :"Y}7EAplW_2SF4*W>mJSb%q)fhw/t`LAW4u_Zrrfyr:t7%/1NY<Tm8E4|;(p(F0c5"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"!3q[7e7gtCU90{g6CKkc:SRHK!G><i<ET3*C7H2AI~SfpSw7ynHG&atw.??WdrS*"
  set vm_args: "rel/vm.args"
  set post_start_hooks: "rel/hooks/post_start"
  set commands: [
    echo: "rel/commands/echo.sh",
    load_prod_jobs: "rel/hooks/post_start/load_prod_jobs.sh"
  ]
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix distillery.release`, the first release in the file
# will be used by default

release :crow do
  set version: "0.1.0"
  set applications: [
    :runtime_tools,
    crow_data: :permanent,
    crow_web: :permanent
  ]
end

