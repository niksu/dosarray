#!/usr/bin/env python3
# Analyse logs from load polling experiments to compile stats for graphing.
# Nik Sultana, UPenn, February 2018.
#
# Use of this source code is governed by the Apache 2.0 license; see LICENSE
#
# Generate load stats of some type (CPU load, memory, or network).
# Each of these is associated with a file suffix (e.g., _net.log) and a regex for that file.
# We open each of the relevant logs, and read them line by line.
# Then emit the stats in the format needed for the type of graph that'll be produced for that kind of target stat.
# For 'net' we normalise wrt the first reading. For 'mem' we normalise wrt total memory.
#
# The script supports multiple runs of an experiment, and emit min,avg,max values.
# NOTE 'net' stats are split into 'net_rx', 'net_tx', 'net_rx_errors', and 'net_tx_errors'.
# NOTE all outputs will be used to generate one type of graph: a bar-char with whiskers.
#
# Example usage:
#   python generate_load_chart.py -p testdata/1 testdata/2 -i 5 -t net_rx -o row
#   python generate_load_chart.py -p testdata/1 testdata/2 -i 5 -t load -o column -m dedos01 dedos02 dedos03 dedos04 dedos05 dedos06 dedos07 dedos08

import argparse
import glob
import os
import re
import sys

suffix_of_load = "_load.log"
regex_of_load = "^.+? .+? (.+?) .+$" #e.g., dedos01 1519446241 0.28 0.07 0.02 2/270 54569
suffix_of_mem = "_mem.log"
regex_of_mem = "MemTotal: (.+?) kB .+ MemAvailable: (.+?) kB$" #e.g., dedos01 1519446241 MemTotal: 65725704 kB MemFree: 15001452 kB MemAvailable: 64497332 kB
suffix_of_net = "_filtered_net.log"
# RX packets errors, TX packets errors
regex_of_net = "^.+: \d+ +(\d+) +(\d+) +\d+ +\d+ +\d+ +\d+ +\d+ +\d+ +(\d+) +(\d+)" #e.g., em1: 116098217270 542764389    0  470    0     0          0      3233 81890469046 548678573    0    0    0     0       0          0

argparser = argparse.ArgumentParser(description = "Process load stats for graphing")
argparser.add_argument('-p', help = "Path containing input files. Use multiple paths to contain files from different runs. The number of files in each path (and the naming policy) should be consistent", nargs = "+", required = True)
argparser.add_argument('-i', help = "Sampling interval (in seconds)", type = int, required = True)
argparser.add_argument('-t', help = "Type of log being processed {load, mem, net_rx, net_tx, net_txerrors, net_rxerrors}", required = True)
argparser.add_argument('-o', help = "Type of output sought {column (default), row, dump}", default = "column")
argparser.add_argument('-m', help = "Order in which to list the machines", nargs = "+", required = True)
args = argparser.parse_args()

sys.stderr.write("-p " + str(args.p) + '\n')
sys.stderr.write("-i " + str(args.i) + '\n')
sys.stderr.write("-t " + args.t + '\n')
sys.stderr.write("-o " + args.o + '\n')
sys.stderr.write("-m " + str(args.m) + '\n')

results = {}
initial_packet_count = {}

if args.t == 'load':
  suffix = suffix_of_load
  regex = regex_of_load
elif args.t == 'mem':
  suffix = suffix_of_mem
  regex = regex_of_mem
elif args.t == 'net_rx' or args.t == 'net_tx' or args.t == 'net_rxerrors' or args.t == 'net_rxerrors':
  suffix = suffix_of_net
  regex = regex_of_net
else:
  sys.stderr.write('Unrecognised -t parameter: ' + args.t + '\n')
  exit(1)

if args.o != 'column' and args.o != 'row' and args.o != 'dump':
  sys.stderr.write('Unrecognised -o parameter: ' + args.o + '\n')
  exit(1)

machinecount = 0

for path in args.p:
  glob_of_logs = path + '/*' + suffix

  sys.stderr.write('Drawing logs from ' + glob_of_logs + '\n')
  filecount = 0

  open_files = []

  for filepath in glob.iglob(glob_of_logs):
    sys.stderr.write('Opening ' + filepath + '\n')
    filecount += 1
    open_files.append((filepath, open(filepath)))
    results[filepath] = []
    initial_packet_count[filepath] = {}

  assert filecount > 0
  if machinecount == 0:
    machinecount = filecount
  else:
    # Each path should contain the same number of files, which should equate to the number of physical hosts we're polling.
    assert machinecount == filecount

  sys.stderr.write("Processing " + str(filecount) + " files in " + path + "\n")

  linecount = 0
  matchcount = 0
  completed_files = 0
  while completed_files < filecount:
    for filepath, file in open_files:
      assert matchcount == linecount
      line = file.readline().rstrip()
      if not line:
        file.close()
        completed_files += 1
        continue
      linecount += 1
      matcher = re.search(regex, line)
      if not matcher:
        sys.stderr.write("Could not match '" + line + "' with '" + regex + "'\n")
      else:
        matchcount += 1
        if args.t == 'load':
          load = float(matcher.group(1))
          results[filepath].append({'load' : load})
        elif args.t == 'mem':
          mem_free = int(matcher.group(1))
          mem_available = int(matcher.group(2))
          mem_usage = 1.0 - (float(mem_available) / float(mem_free))
          results[filepath].append({'mem_usage' : mem_usage})
        elif args.t == 'net_rx' or args.t == 'net_tx' or args.t == 'net_rxerrors' or args.t == 'net_rxerrors':
          rx_packets = int(matcher.group(1))
          rx_errors = int(matcher.group(2))
          tx_packets = int(matcher.group(3))
          tx_errors = int(matcher.group(4))
          if len(results[filepath]) == 0:
            initial_packet_count[filepath] = {'rx_packets' : rx_packets, 'rx_errors' : rx_errors, 'tx_packets' : tx_packets, 'tx_errors' : tx_errors}
            results[filepath].append({'rx_packets' : 0, 'rx_errors' : 0, 'tx_packets' : 0, 'tx_errors' : 0})
          else:
            initial_rx_packets = initial_packet_count[filepath]['rx_packets']
            initial_rx_errors = initial_packet_count[filepath]['rx_errors']
            initial_tx_packets = initial_packet_count[filepath]['tx_packets']
            initial_tx_errors = initial_packet_count[filepath]['tx_errors']
            results[filepath].append({'rx_packets' : rx_packets - initial_rx_packets, 'rx_errors' : rx_errors - initial_rx_errors, 'tx_packets' : tx_packets - initial_tx_packets, 'tx_errors' : tx_errors - initial_tx_errors})

        else:
          sys.stderr.write('Unrecognised -t parameter: ' + args.t + '\n')
          exit(1)

  if args.t == 'net_rx' or args.t == 'net_tx' or args.t == 'net_rxerrors' or args.t == 'net_rxerrors':
    sys.stderr.write('initial_packet_count: ' + str(initial_packet_count) + '\n')

def extract_machine_name(filename):
  matcher = re.search("^.+/(.+)" + suffix + "$", filename)
  if not matcher:
    sys.stderr.write('Could not extract machine name from filename: ' + filename + '\n')
    exit(1)
  return matcher.group(1)

factored_results = {}
for filename in results:
  machine_name = extract_machine_name(filename)
  if not machine_name in factored_results:
    factored_results[machine_name] = []
  factored_results[machine_name].append(results[filename])

# Check that all the runs of the experiment produced the same number of samples.
number_of_samples = 0
for machine_name in factored_results:
  for single_data_batch in factored_results[machine_name]:
    if number_of_samples == 0:
      number_of_samples = len(single_data_batch)
    else:
      assert number_of_samples == len(single_data_batch)
assert number_of_samples > 0

def generate_processed_results(field):
  processed_results = {}
  for machine_name in factored_results:
    processed_results[machine_name] = []
    for i in range(0, number_of_samples):
      min = None
      max = None
      tot = 0
      for item in factored_results[machine_name]:
        if min == None:
          min = item[i][field]
        else:
          if min > item[i][field]: min = item[i][field]

        if max == None:
          max = item[i][field]
        else:
          if max < item[i][field]: max = item[i][field]

        tot += item[i][field]
      processed_results[machine_name].append({'min' : min,
          'avg' : float(tot) / float(len(factored_results[machine_name])),
          'max' : max})
  return processed_results

# Produce the requested output
if args.o == 'dump':
  def emit_results(format_output_f):
    pass
  print("results = " + str(results))
  print("factored_results = " + str(factored_results))
elif args.o == 'row':
  print("# machine_name, time, min, avg, max")
  def emit_results(field):
    processed_results = generate_processed_results(field)

    machines = []
    if not args.m:
      for machine_name in factored_results:
        machines.append(machine_name)
    else: machines = args.m

    for machine_name in machines:
      time = 0
      for i in range(0, number_of_samples):
        print(machine_name + " " + str(time) + " " +
                str(processed_results[machine_name][i]['min']) + " " +
                str(processed_results[machine_name][i]['avg']) + " " +
                str(processed_results[machine_name][i]['max']))
        time += args.i
elif args.o == 'column':
  machines = []
  if not args.m:
    for machine_name in factored_results:
      machines.append(machine_name)
  else: machines = args.m
  print("# machine_name sequence : " + str(machines))
  print("# time, (min, avg, max)+")
  def emit_results(field):
    processed_results = generate_processed_results(field)
    time = 0
    for i in range(0, number_of_samples):
      line = str(time) + " "
      for machine in machines:
        line += (str(processed_results[machine][i]['min']) + " " +
                str(processed_results[machine][i]['avg']) + " " +
                str(processed_results[machine][i]['max']) + " ")
      print line
      time += args.i
else:
  sys.stderr.write('Unrecognised -o parameter: ' + args.o + '\n')
  exit(1)

if args.t == 'load':
  emit_results('load')
elif args.t == 'mem':
  emit_results('mem_usage')
elif args.t == 'net_rx':
  emit_results('rx_packets')
elif args.t == 'net_tx':
  emit_results('tx_packets')
elif args.t == 'net_rxerrors':
  emit_results('rx_errors')
elif args.t == 'net_txerrors':
  emit_results('tx_errors')
else:
  sys.stderr.write('Unrecognised -t parameter: ' + args.t + '\n')
  exit(1)
