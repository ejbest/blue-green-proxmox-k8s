#!/bin/bash
export CI_TRIGGER_TOKEN=${CI_TRIGGER_TOKEN} \
export ENV=green-ci \
export JOB=destroy \
export BRANCH=main &&
curl -X POST \
--fail \
-F token=$CI_TRIGGER_TOKEN \
-F ref=$BRANCH \
-F variables[ENV]=$ENV \
-F variables[JOB]=$JOB \
https://gitlab.com/api/v4/projects/53399140/trigger/pipeline