#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"
readonly TEST_FILES=(${MY_DIR}/../*_test.rb)
readonly TEST_LOG=${COVERAGE_ROOT}/test.log
readonly ARGS=(${*})

mkdir -p ${COVERAGE_ROOT}

ruby \
  -e "([ '${MY_DIR}/coverage.rb' ] + \
         %w(${TEST_FILES[*]})        \
      ).each{ |file| require file }" \
  -- ${ARGS[@]}                      \
  | tee ${TEST_LOG}

ruby ${MY_DIR}/check_test_results.rb \
  ${TEST_LOG} \
  ${COVERAGE_ROOT}/index.html \
    > ${COVERAGE_ROOT}/done.txt
