/opt/shared/hadoop/bin/hadoop jar \
        /opt/shared/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar \
        wordcount \
        /user/yarn/wordcount/input \
        /user/yarn/wordcount/output-`date +%Y%m%d-%H%M%S`
