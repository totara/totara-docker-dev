#!/bin/bash
# You can create your own helpers by creating a new .sh file in this directory, which will also get sourced into the php containers.

# Create a test course
create_course() {
  run_totara_cmd php admin/tool/generator/cli/maketestcourse.php --shortname=course --size=S $@
}
alias createcourse='create_course'

# Create a test user
create_user() {
  run_totara_cmd php totara/generator/cli/maketestuser.php $@
}
alias createuser='create_user'

# Create many test courses
create_courses() {
  local count=${1:-20}
  local prefix=${2:-course}

  local pad_width=${#count}

  echo -n "Creating $count courses"
  for ((i = 1; i <= count; i++)); do
    printf -v num "%0*d" "$pad_width" "$i"
    php server/admin/tool/generator/cli/maketestcourse.php \
      --shortname="${prefix}${num}" \
      --fullname="${prefix} ${num}" \
      --size=XS \
      --quiet
    echo -n "."
  done
  echo "done!"
}
alias createcourses='create_courses'
