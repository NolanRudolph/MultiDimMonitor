from subprocess import Popen, PIPE
import os

#sudo bash add_latency.sh eth0 128.104.222.68 0ms
YCSB_WPATH='./YCSB/workloads/'
YCSB_PATH='./YCSB/'
EDITED_WORKLOAD = './edited/';
remote_ip = '128.104.222.68';
#bash run_remote.sh 128.104.222.68 switch_to.sh disk
remote_command = ('bash run_remote.sh ' + remote_ip).split();
ethi = 'eth0';
rem_db_f = 'clear_db.sh';

print(remote_command)

num_threads = [1, 2, 4, 8, 16];
my_num_threads = num_threads[2:];
workloads = [chr(ord('a') + i) for i in range(6)];
my_workloads = workloads[1:];
num_runs = 3;
field_length = [int((2**(10+i))/10) for i in range(5)];

def run_process(command):
    p = Popen(command, stdout=PIPE, stderr=PIPE, universal_newlines=True);
    code_out, err = p.communicate();
    return code_out, err;


prev = {'ssd' : -1, 'disk': -1};

for fl in field_length:
    if fl > 450:
        my_num_threads = num_threads;
        my_workloads = workloads;
    if fl < 400:
        continue;
    for t in my_num_threads:
        for workload in my_workloads:
            filepath = YCSB_WPATH + 'workload' + workload;
            if workload == 'e':
                continue;
            else:
                workload_file = open(filepath);
                old_content = workload_file.read();
                workload_file.close();
                line_to_add = 'fieldlength=' + str(fl) + '\n';
                new_content = old_content + '\n' + line_to_add;
#print(old_content);
#               print(new_content);
                if not os.path.exists(EDITED_WORKLOAD):
                    os.makedirs(EDITED_WORKLOAD);
                edw_path = EDITED_WORKLOAD + 'workload' + workload;
                new_wfile = open(edw_path, 'w');
                new_wfile.write(new_content);
                new_wfile.close();
                ## load the workload here first and clear everything from the remote db
                ## then run the workload however many times you need
                ## make sure the latency is zero
                cout, cerr = run_process(('sudo bash add_latency.sh ' + ethi + ' ' + remote_ip + ' 0ms').split());
                #print(float(cout.split('\n')[1].split(',')[-1]));
                baseline = [0.0, 0.0];
                count = 0;
                for dev in ['disk', 'ssd']:
                    ycsb_command = ('bin/ycsb load cassandra-cql -P ../' + edw_path +\
                        ' -p hosts=' + remote_ip + ' -threads ' + str(t)).split();
                    print(remote_command + ['switch_to.sh', dev]);
                    #bash run_remote.sh 128.104.222.68 switch_to.sh disk 
                    cout, cerr = run_process(remote_command + ['switch_to.sh', dev]); #switch to dev
                    print('Error While switching if any: ', cerr);
                    #####################################
                    print(remote_command);
                    cwd = os.getcwd();
                    os.chdir(YCSB_PATH);
                    if prev[dev] != fl:
                        cout, cerr = run_process(remote_command + [rem_db_f]); #clears the remote db
                        print('Error while clearning db if any: ', cout, '\n', cerr);
                        ycsb_command[-1] = '16';
                        print(ycsb_command);
                        cout, cerr = run_process(ycsb_command); #loads the data into the db
                        ycsb_command[-1] = str(t)
                        prev[dev] = fl;
                    
                    ycsb_command[1] = 'run';
                    for i in range(num_runs):
                        cout, cerr = run_process('bash ../run_remote.sh 128.104.222.68 ../clear_cache.sh'.split()); #clear the cache
                        print('Errors while clearing the cache if any: ', cout, '\n', cerr);
                        cout, cerr = run_process(ycsb_command);
                        print(cout.split());
                        baseline[count] += float(cout.split('\n')[1].split(',')[-1]);
                    baseline[count] /= num_runs;
                    count += 1;
                    print(cout);
                    print(dev + ': ' + str(baseline[count - 1]));
                    os.chdir(cwd);
                    #####################################
                if not os.path.exists('./output'):
                    os.makedirs('./output');
                outputfile = open('./output/'+str(t)+'_'+str(fl)+'_'+str(workload)+'.csv', 'w');
                outputfile.write('baseline,ssdThroughput,addedLatency\n');
                outputfile.write(str(baseline[0])+','+str(baseline[1])+','+'0ms\n');
                cwd = os.getcwd();
                os.chdir(YCSB_PATH);
                num_tries = 2;
                curr_latency = 0.5;
                while (num_tries >= 0) or (baseline[1] > baseline[0]):
                    cout, cerr = run_process(('sudo bash ../add_latency.sh ' + ethi + ' ' \
                                + remote_ip + ' ' + str(curr_latency) + 'ms').split());
                    print('Error while adding latency: ', cerr);
                    curr_thrpt = 0.0;
                    for i in range(num_runs):
                        cout, cerr = run_process('bash ../run_remote.sh 128.104.222.68 ../clear_cache.sh'.split()); #clear the cache
                        print('Errors while clearing the cache if any: ', cerr);
                        cout, cerr = run_process(ycsb_command);
                        print(cout.split());
                        curr_thrpt += float(cout.split('\n')[1].split(',')[-1]);
                    curr_thrpt /= num_runs;
                    baseline[1] = curr_thrpt;
                    outputfile.write(str(baseline[0])+','+str(baseline[1])+','+str(curr_latency)+'ms\n');
                    curr_latency += 0.5;
                    if baseline[0] > baseline[1]:
                        num_tries -= 1;
                os.chdir(cwd);
                outputfile.close();
