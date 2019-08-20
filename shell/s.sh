
while [ 1 ]
do
echo `date` >> netstat_i.out
echo `date` >> netstat_s.out
echo `date` >> softirqs.out
echo `date` >> softnet_sta.out
echo `date` >> nstat.out
echo `date` >> ss_nt.out
netstat -i  >> netstat_i.out
netstat -s  >> netstat_s.out
nstat -az >> nstat.out
ss -ntopmie >> ss_nt.out
cat /proc/softirqs >> softirqs.out
cat /proc/net/softnet_stat >> softnet_sta.out
sleep 2
done




