#!/bin/sh
set -e

# Figure out where this script is located.
export SELFDIR="`dirname \"$0\"`"
export SELFDIR="`cd \"$SELFDIR\" && pwd`"
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

# Run the actual app using the bundled Ruby interpreter.
if [ $# -ne 0 ]; then
  exec "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/lib/cloudstats.rb" $@
else
  exec "$SELFDIR/keepalive" "$SELFDIR/lib/ruby/bin/ruby" -rbundler/setup "$SELFDIR/lib/app/lib/cloudstats.rb"
fi
