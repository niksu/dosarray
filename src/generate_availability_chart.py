#!/usr/bin/env python3
# Analyse logs from availability experiments to compile availability charts.
# Nik Sultana, UPenn, December 2017
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# command time ./generate_availability_chart.py 'exp1_evernbigger2/baseline_40s_for_ge/c*.log' > availability_chart.data_ge_base
# and: DOSARRAY_NHIST_RESULT=1 python generate_availability_chart.py '/Users/nik/t/xoghol/Penn/bitbucket/dedos_docs/papers/chipchip/experiment/apache_worker_sl_40inst_winnow24_with_cache/c*.log'

import datetime
import glob
import os
import re
import sys

if 'DOSARRAY_VERSION' not in os.environ:
  sys.stderr.write('generate_availability_chart.py: DOSARRAY_VERSION was not found in environment\n')

if 'DOSARRAY_NHIST_RESULT' in os.environ: histogram_result = False
else: histogram_result = True
sys.stderr.write('DOSARRAY_NHIST_RESULT:' + str(not histogram_result) + '\n')

if 'DOSARRAY_HIST_FOCUS' in os.environ: histogram_focus = int(os.environ['DOSARRAY_HIST_FOCUS'])
else: histogram_focus = None
sys.stderr.write('DOSARRAY_HIST_FOCUS:' + str(histogram_focus) + '\n')

result = {}

# Latency-related configuration parameters
precision = 10.0 # where 1 = 1ms, 10 = 0.1ms, etc. Httping reports outputs in milliseconds, but in the experiments they tend to be less than 1ms.
latency_cutoff = 1.0
latency_offset = 0.0
latency_scale = 10.0

# Latency-related outputs
average_latency = 0.0
latency_cutoff_applied_times = 0 # Keeps track of how many times the cutoff was actually applied.

min_seq_idx = -1
max_seq_idx = -1

glob_of_logs = sys.argv[1]

sys.stderr.write('Drawing logs from ' + glob_of_logs + '\n')
filecount = 0
linecount = 0
matchcount = 0
for filepath in glob.iglob(glob_of_logs):
  filecount += 1
  with open(filepath) as file:
    for line in file:
      linecount += 1
      matcher = re.search('connected .* seq=(\d+) time=(.+) ms', line)
      if matcher:
        matchcount += 1
        sequence_idx = int(matcher.group(1))

        if sequence_idx < min_seq_idx or min_seq_idx == -1:
          min_seq_idx = sequence_idx
        if sequence_idx > max_seq_idx or max_seq_idx == -1:
          max_seq_idx = sequence_idx


        if not histogram_result:
          if not sequence_idx in result:
            result[sequence_idx] = 0
          result[sequence_idx] += 1
        else:
          latency = float(matcher.group(2))

          assert 0.0 < latency

          average_latency = (average_latency + latency) / 2

          latency -= latency_offset
          latency /= latency_scale

          # NOTE this next bit is in place because of artefacts that occur sometimes.
          # assert latency < latency_cutoff
          if latency > latency_cutoff:
            latency_cutoff_applied_times += 1
            continue

          latency_approx = int(latency * precision)
          #assert latency_approx < int(latency_cutoff * precision)
#          if latency_approx >= int(precision):
#            sys.stderr.write('Precision too low: need at least ' + str(latency_approx) + '\n')
#            latency_approx = int(precision) - 1
          if not int(latency_approx) <= int(latency_cutoff * precision):
            sys.stderr.write('latency_approx ' + str(latency_approx) + ' exceeds cutoff (' + str(latency_cutoff * precision) + ')\n')

          if not sequence_idx in result:
            result[sequence_idx] = {}
            for latency_bucket in range(0, int(precision) + 1):
              result[sequence_idx][latency_bucket] = 0

          result[sequence_idx][latency_approx] += 1
#          print(str(sequence_idx) + ", " + str(latency_approx))
#          print(str(latency_approx))   # for bell curve for whole set of logs     
#      else: sys.stderr.write('unmatched line: "' + line + '"\n')

sys.stderr.write('min_seq_idx: ' + str(min_seq_idx) + '\n')
sys.stderr.write('max_seq_idx: ' + str(max_seq_idx) + '\n')

assert min_seq_idx > -1
assert max_seq_idx > -1
assert min_seq_idx < max_seq_idx

sys.stderr.write('Files processed: ' + str(filecount) + '\n')
sys.stderr.write('Total lines processed: ' + str(linecount) + '\n')
sys.stderr.write('Total echos received: ' + str(matchcount) + ', ~' + str((float(matchcount) / float(linecount)) * 100) + '% \n')
sys.stderr.write('latency_cutoff_applied_times: ' + str(latency_cutoff_applied_times) + '\n')
if latency_cutoff_applied_times > 0:
  sys.stderr.write('WARNING! Non-zero latency_cutoff_applied_times\n')
sys.stderr.write('average_latency: ' + str(average_latency) + '\n')

# We'll use this to calculate the percentage of each column in the histogram,
# rather than use absolute values. (e.g., "11%" rather than "17 instances").
total_instances = -1

# Instead of "z" being a total, have it be a normalised value (percentage of all instances, rather than the number of instances)
#for idx in range(min_seq_idx, max_seq_idx):
#  if idx in result:
#    for latency_bucket in range(0, int(precision)):
#      print (str(idx) + " " + str(latency_bucket * int(precision)) + " " + str(result[idx][latency_bucket]))

print("# Generated by DoSarray v" + os.environ['DOSARRAY_VERSION'] + " on " + datetime.datetime.now().strftime("%Y-%m-%d %H:%M"))

for idx in range(min_seq_idx, max_seq_idx):
  if idx in result:
    current_total_instances = 0
    if not histogram_result:
      current_total_instances += result[idx]
    else:
      for latency_bucket in range(0, int(precision) + 1):
        current_total_instances += result[idx][latency_bucket]

    if total_instances == -1:
      total_instances = current_total_instances
    # assert total_instances == current_total_instances NOTE disabled this
    #   since it breaks down if an attack starts (since some instances would
    #   stop responding, so the "current_total_instances" would seem to get
    #   smaller than "total_instances", thus breaking the assertion.
    elif total_instances < current_total_instances:
      # In case our first value for total_instances was lower than what was possible.
      total_instances = current_total_instances

for idx in range(min_seq_idx, max_seq_idx):
  if not histogram_result:
    if idx in result:
      percentage = 100.0 * round(float(result[idx] / float(total_instances)), 2)
    else:
      percentage = 0.0
    print (str(idx) + " " + str(percentage))
  else:
    if idx in result and (histogram_focus == None or histogram_focus == idx):
      total_of_idx = 0
      for latency_bucket in range(0, int(precision) + 1):
        percentage = 100.0 * round(float(result[idx][latency_bucket]) / float(total_instances), 2)
        #percentage = result[idx][latency_bucket]
        print (str(idx) + " " + str(latency_bucket) + " " + str(percentage))     

        total_of_idx += result[idx][latency_bucket]
      #print (str(idx) + " " + str(total_of_idx)) # This should always equal the number of hosts on the network     

sys.stderr.write('Total instances inferred: ' + str(total_instances) + '\n')
