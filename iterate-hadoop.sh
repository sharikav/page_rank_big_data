#!/bin/sh
CONVERGE=1
rm v* log*
I=1
#$HADOOP_HOME/sbin/start-all.sh
$HADOOP_HOME/bin/hadoop dfsadmin -safemode leave
hdfs dfs -rm -r /output* 

$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-*streaming*.jar \
-mapper "python3 /home/nitish/hadoop/pagerank/mapper_t1.py" \
-reducer "python3 /home/nitish/hadoop/pagerank/reducer_t1.py '/home/nitish/hadoop/pagerank/v'"  \
-input input/web-Google.txt \
-output /output1 #has adjacency list


while [ "$CONVERGE" -ne 0 ]
do	
	echo $I
	$HADOOP_HOME/bin/hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-*streaming*.jar \
	-mapper "python3 /home/nitish/hadoop/pagerank/mapper_t2.py '/home/nitish/hadoop/pagerank/v' " \
	-reducer "python3 /home/nitish/hadoop/pagerank/reducer_t2.py" \
	-input /output1 \
	-output /output2
	touch v1
	hadoop fs -cat /output2/* > /home/nitish/hadoop/pagerank/v1
	CONVERGE=$(python3 /home/nitish/hadoop/pagerank/check_conv.py >&1)
	hdfs dfs -rm -r /output2
	echo $CONVERGE
	I=`expr $I + 1`
	

done
