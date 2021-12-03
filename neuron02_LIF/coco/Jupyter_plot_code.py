import numpy as np
tim = 10000
np.set_printoptions(threshold=np.inf)
from matplotlib import pyplot as plt 
from brian2 import *

%cd /home/huiseong/neuron_workspace/neuron02_LIF/coco
!make

val = np.load('val.npy')
lid_val = np.load('lid_val.npy')
lid_sp = np.load('lid_sp.npy')
exd_val = np.load('exd_val.npy')
exd_sp = np.load('exd_sp.npy')
tarray = np.arange(0,tim) 

plt.plot(tarray,lid_val)

val_bool = np.zeros(tim)
for i in range(tim):
    if(val[i]>0):
        val_bool[i]=1
    else:
        val_bool[i]=0

figure(figsize=(16,8))  # config plot size
start_scope()
tau = 1024*ms
dt = 1*ms

stimulus = TimedArray((list(val)*mV)/(2**31), dt=1*ms)
eqs = '''
dv/dt = stimulus(t)/ms + (-v)/tau  : volt
'''
G = NeuronGroup(1, eqs, threshold='v>1*mV', reset='v = 0.00419095*mV',dt=1*ms)
spikemon = SpikeMonitor(G)
M = StateMonitor(G, 'v', record=0)
run(tim*ms)
plt.plot(M.t/ms, M.v[0]*1000,color='C2')
for t in spikemon.t:
    axvline(t/ms, ls='--', c='C2', lw=3)
#plt.plot(M.t/ms, M.v[0],tarray,lid_val/4294967296)
plt.plot(M.t/ms,lid_val/(2**31),color='r')
plt.plot(M.t/ms, val_bool/-10,linewidth=4)
#red: verilog
#GReen: brian2 