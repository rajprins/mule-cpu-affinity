# How to set CPU affinity for a Mule ESB process


## Problem

You want to run Mule ESB in a non-virtualized multi-core server, and at the same time keep the compliance with the number of cores entitled by your subscription.


## Solution

Many operating systems provide some mechanism to set the CPU affinity for a process. Below you can find the procedure for both Linux and Solaris. If you are using some other operating system, you should check the documentation in order to find the equivalent command for your specific platform.

Important: CPUs will always have groups of cores that share a cache where thread communication and migration is cheaper. You should ask your infrastructure team to verify what cores shared this cache, so you can avoid unnecessary context switches.

Caveat: MacOS does not offer out-of-the-box CPU affinity features as a result of the XNU kernel design.


### On Linux

The taskset command can be used to limit the amount of cores that the Mule server can use. This command must be used every time the server is started or restarted.

The following example shows how core 0 and 1 can be assigned to a Mule instance at creation time:

`taskset -c 0,1 ./mule`

In the next example, the CPU affinity is set at restart time:

`taskset -c 0,1 ./mule restart`

These Bash scripts allow you to monitor and set the affinity of your Mule instance to a set of cores.

The `affinity-set` script allows you to set the affinity while your Mule instance is executing. 

Example: set CPU 0 and 1 to process 1234 and all it's children:

`./affinity-set.sh 1234 0,1`

The `affinity-monitor` script shows you the process tree and the cores assigned to each process and sub-process.

`./affinity-monitor.sh 1890`

```
***   AFFINITY MONITOR START -  Sun Feb 10 21:02:10 ARST 2013    ***  
Process tree:  
mule(1890)---mule(1947)---wrapper-linux-x(2019)-+-java(2021)-+-{java}(2022)  
                                                |            |-{java}(2023)  
                                                |            |-{java}(2024)
                                                |            |-{java}(2025)
                                                |            |-{java}(2026)
                                                |            |-{java}(2027)
                                                |            |-{java}(2028)
                                                |            |-{java}(2029)
                                                |            |-{java}(2030)
                                                |            |-{java}(2031)
                                                |            |-{java}(2032)
                                                |            |-{java}(2033)
                                                |            |-{java}(2034)
                                                |            |-{java}(2035)
                                                |            |-{java}(2038)
                                                |            |-{java}(2040)
                                                |            |-{java}(2041)
                                                |            |-{java}(2042)
                                                |            `-{java}(2043)
                                                `-{wrapper-linux-x}(2020)


Process affinity:
pid 1890's current affinity list: 1
pid 1947's current affinity list: 1
pid 2019's current affinity list: 1
pid 2021's current affinity list: 1
pid 2022's current affinity list: 1
pid 2023's current affinity list: 1
pid 2024's current affinity list: 1
pid 2025's current affinity list: 1
pid 2026's current affinity list: 1
pid 2027's current affinity list: 1
pid 2028's current affinity list: 1
pid 2029's current affinity list: 1
pid 2030's current affinity list: 1
pid 2031's current affinity list: 1
pid 2032's current affinity list: 1
pid 2033's current affinity list: 1
pid 2034's current affinity list: 1
pid 2035's current affinity list: 1
pid 2038's current affinity list: 1
pid 2040's current affinity list: 1
pid 2041's current affinity list: 1
pid 2042's current affinity list: 1
pid 2043's current affinity list: 1
pid 2020's current affinity list: 1
***   AFFINITY MONITOR END -  Sun Feb 10 21:02:10 ARST 2013    ***  
```


### On Solaris

In order to enforce the number of cores used by Mule ESB in Solaris 10 and newer versions, you can try the following procedure:


1 - Create a list of available virtual processors running the command psrinfo

```
~$ psrinfo
0 on-line since 09/29/2014 11:53:17
1 on-line since 09/29/2014 11:53:18
2 on-line since 09/29/2014 11:53:18
3 on-line since 09/29/2014 11:53:18
```

2 - Create a processor set using the psrset command, passing as arguments the list of virtual processors where you want to run Mule:

```
~$ psrset -c 2-3
created processor set 1
processor 2: was not assigned, now 1
processor 3: was not assigned, now 1
```

3 - Run Mule in the newly created processor set:

```
~$ psrset -e 1 ./mule -M-Dmule.mmc.bind.port=8888
```

Note that you can pass arguments to the command being executed in the processor set.

### On Windows

You can use the "start" command to run the mule.bat executable:
```
c:\mule\bin> start /affinity n mule 
```
Where n is the HexAffinity Mask. An affinity mask is a bit mask indicating which CPU Cores a process should use. 

For example, this will give only 2 cores:

```
c:\mule\bin> start /affinity 3 mule 
```
The example above will set CPU 0 and CPU 1 to the Mule process. To set a different affinities, for each CPU number you want to run the application, replace 0 (off) with 1 (on) in a binary number that represent all your CPUs and then transform that binary number to hexadecimal. 

For example, for 12 CPU host, if I wanted to run the application only on CPU 0, then the binary number would be 000000000001. To run the application with CPU 0 and CPU 3, I would be 000000001001. Then just transform that binary number to hexadecimal. 000000001001 will be 9, so to run mule with CPU 0 and CPU 3 instead, you can run:
```
c:\mule\bin> start /affinity 9 mule
```