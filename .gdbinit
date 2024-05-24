set pagination off
set history save on
set history expansion on
# set debuginfod enabled on
set breakpoint pending on
set print pretty on
# set logging enabled on
set trace-commands on
python print('Hello from python!')


define hookpost-next
  refresh
end
define hookpost-step
  refresh
end
define hookpost-continue
  refresh
end
define hookpost-run
  refresh
end
define hookpost-stop
  refresh
end
define hookpost-finish
  refresh
end

define hook-next
  refresh
end
define hook-step
  refresh
end
define hook-continue
  refresh
end
define hook-run
  refresh
end
define hook-stop
  refresh
end
define hook-finish
  refresh
end
