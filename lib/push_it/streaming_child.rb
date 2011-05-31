require "posix/spawn"

module PushIt

  class StreamingChild < POSIX::Spawn::Child
  end

end