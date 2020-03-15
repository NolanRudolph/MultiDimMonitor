import matplotlib.pyplot as plt
import numpy as np


def plot_throughputs(ax, bar_width, val_size, workload):
     init_pos = 0.5;
     ssd = [];
     disk = [];
     labels = [];
     ticks1 = np.array([init_pos + i for i in range(5)]);
     ticks2 = np.array([init_pos + bar_width + i for i in range(5)]);
     for t in [1, 4, 16]:
          filename = str(t) + '_' + str(val_size) + '_' + workload + '.csv';
          data_file = open(filename);
          data_file.readline(); 
          data_line = data_file.readline().split(',');
          data_file.close();
          disk.append(float(data_line[0])); ssd.append(float(data_line[1]));
          labels.append('Threads ' + str(t));
     disk_bar = ax.bar(ticks1, disk, bar_width, color='white', edgecolor='black', hatch='/');
     ssd_bar = ax.bar(ticks2, ssd, bar_width, color='white', edgecolor='black', hatch='o');
     ax.set_xticks(ticks2 - bar_width/2);
     ax.set_xticklabels(labels);
     for tick in ax.yaxis.get_major_ticks():
          tick.label.set_fontsize(14);
     for tick in ax.xaxis.get_major_ticks():
          tick.label.set_fontsize(14);
     ax.legend((disk_bar[0], ssd_bar[0]), ('disk', 'ssd'));
     ax.set_ylabel('Throughput (ops/sec)', fontsize=8);
     ax.text(.5,.9,'Workload ' + workload,
        horizontalalignment='center',
        transform=ax.transAxes, fontsize=10)
     # ax.set_xlabel('Threads', fontsize=8);
     # ax.set_title('Workload ' + workload, fontsize=10);

     return;


bar_width = 0.4;
fig= plt.figure();#subplots(2, 2, figsize=(6,6));
fig.suptitle('Throughput for Different Workloads');
ax1 = fig.add_subplot(321)
ax2 = fig.add_subplot(323)
ax3 = fig.add_subplot(325)
ax4 = fig.add_subplot(222)
ax5 = fig.add_subplot(224)
axes = [ax1, ax2, ax3, ax4, ax5];

# plt.setp(axes, xticks=[], xticklabels=[],
#         yticks=[])

# for ax in axes:
#      ax.set_xticks([]);
#      ax.set_yticks([]);

workloads = ['a', 'b', 'c', 'd', 'f'];
w_ind = 0;
val_size = 102;

for ax in axes:
     plot_throughputs(ax, bar_width, val_size, workloads[w_ind]);
     w_ind += 1;

fig, ax = plt.subplots(1, 1);

workload_under_consideration = 'a';
val_size = 102;

def plot_throughput(ax, workload_under_consideration, val_size, threads, markers, labels):
     data_file = open(threads + '_' + str(val_size) + '_' + workload_under_consideration + '.csv');
     data_file.readline();
     x_axis = []; baseline = []; ssd = [];

     for line in data_file:
          data = [ float(x) if x[-2:] != 'ms' else float(x[:-2]) for x in line.strip().split(',') ];
          x_axis.append(data[-1]);
          baseline.append(data[0]);
          ssd.append(data[1]);

     data_file.close();
     ax.plot(x_axis, baseline, color='black', marker=markers[0], label=labels[0]);
     ax.plot(x_axis, ssd, 'k--', marker=markers[1], label=labels[1]);
     ax.set_xlabel('Added RTT Delay (ms)');
     ax.set_ylabel('THroughput (ops/sec)');
     ax.legend();

plot_throughput(ax, workload_under_consideration, val_size, '1', ['^', '^'], ['Disk Throughput for 1 Threads', 'SSD Throughput for 1 Threads']);
# plot_throughput(ax, workload_under_consideration, val_size, '2', ['x', 'x'], ['Disk Throughput for 2 Threads', 'SSD Throughput for 2 Threads']);
plot_throughput(ax, workload_under_consideration, val_size, '4', ['+', '+'], ['Disk Throughput for 4 Threads', 'SSD Throughput for 4 Threads']);
# plot_throughput(ax, workload_under_consideration, val_size, '8', ['p', 'p'], ['Disk Throughput for 8 Threads', 'SSD Throughput for 8 Threads']);
plot_throughput(ax, workload_under_consideration, val_size, '16', ['D', 'D'], ['Disk Throughput for 16 Threads', 'SSD Throughput for 16 Threads']);

fig, ax = plt.subplots(1, 1);

def plot_latency(ax, workload_under_consideration, val_size):
     x_axis = []; latency = [];
     for thread in [1, 2, 4, 8, 16]:
          data_file = open(str(thread) + '_' + str(val_size) + '_' + workload_under_consideration + '.csv');
          data_file.readline();
          x_axis.append(thread)
          
          baseline = -float('inf'); current_ssd = 0; lat = 0.0;
          while current_ssd > baseline:
               line = data_file.readline();
               data = [ float(x) if x[-2:] != 'ms' else float(x[:-2]) for x in line.strip().split(',') ];
               current_ssd = data[1];
               baseline = data[0];
               lat = data[-1];
          latency.append(lat);
          data_file.close();
     ax.plot(x_axis, latency, marker='x', color='k');
     ax.set_xlabel('Number of Threads');
     ax.set_ylabel('Worst case RTT Delay in SSD Node (ms)');

plot_latency(ax, workload_under_consideration, val_size, )

fig, ax = plt.subplots(1, 1);
num_threads = [1];
val_sizes = [102, 204, 409, 819, 1638];
workload_under_consideration = 'a';

def plot_val_size(ax, workload_under_consideration, val_sizes, num_threads):
     x_axis = []; latency = [];
     for t in num_threads:
          for val_size in val_sizes:
               data_file = open(str(t) + '_' + str(val_size) + '_' + workload_under_consideration + '.csv');
               data_file.readline();
               x_axis.append(val_size * 10);
               
               baseline = -float('inf'); current_ssd = 0; lat = 0.0;
               while current_ssd > baseline:
                    line = data_file.readline();
                    data = [ float(x) if x[-2:] != 'ms' else float(x[:-2]) for x in line.strip().split(',') ];
                    current_ssd = data[1];
                    baseline = data[0];
                    lat = data[-1];
               latency.append(lat);
               data_file.close();
          ax.plot(x_axis, latency, marker='x', color='k');
     ax.set_xlabel('Value Size');
     ax.set_ylabel('Worst case RTT Delay in SSD Node (ms)');

plot_val_size(ax, workload_under_consideration, val_sizes, num_threads);   

fig, ax = plt.subplots(1, 1);

workload_under_consideration = 'a';
val_size = [409, 100000];

def plot_throughput(ax, workload_under_consideration, val_sizes, threads):
     markers = [['^', '^'], ['x', 'x']];
     count = 0;
     for vs in val_sizes:
          data_file = open(threads + '_' + str(vs) + '_' + workload_under_consideration + '.csv');
          data_file.readline();
          x_axis = []; baseline = []; ssd = [];
          labels = ['Disk Throughput for ' + str(vs*10) + ' Value Size', 'SSD Throughput for ' + str(vs*10) + ' Value Size'];
          for line in data_file:
               data = [ float(x) if x[-2:] != 'ms' else float(x[:-2]) for x in line.strip().split(',') ];
               x_axis.append(data[-1]);
               baseline.append(data[0]);
               ssd.append(data[1]);
          cmark = markers[count];
          count += 1;
          data_file.close();
          ax.plot(x_axis, baseline, color='black', marker=cmark[0], label=labels[0]);
          ax.plot(x_axis, ssd, 'k--', marker=cmark[1], label=labels[1]);
          ax.set_xlabel('Added RTT Delay (ms)');
          ax.set_ylabel('Throughput (ops/sec)');
          ax.legend();

plot_throughput(ax, workload_under_consideration, val_size, '4');
# plot_throughput(ax, workload_under_consideration, val_size, '2', ['x', 'x'], ['Disk Throughput for 2 Threads', 'SSD Throughput for 2 Threads']);
# plot_throughput(ax, workload_under_consideration, val_size, '4', ['+', '+'], ['Disk Throughput for 4 Threads', 'SSD Throughput for 4 Threads']);
# plot_throughput(ax, workload_under_consideration, val_size, '8', ['p', 'p'], ['Disk Throughput for 8 Threads', 'SSD Throughput for 8 Threads']);
# plot_throughput(ax, workload_under_consideration, val_size, '4', ['D', 'D'], ['Disk Throughput for 16 Threads', 'SSD Throughput for 16 Threads']);

plt.show();
