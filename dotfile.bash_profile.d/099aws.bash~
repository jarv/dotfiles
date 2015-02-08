export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
if [[ -d "$HOME/aws/AWS-ElasticBeanstalk-CLI-2.3/eb/linux/python2.7" ]]; then
    PATH="$HOME/aws/AWS-ElasticBeanstalk-CLI-2.3/eb/linux/python2.7:$PATH"
fi
for aws_dir in AmazonElastiCacheCli-1.8.000; do
    if [[ -d "$HOME/aws/$aws_dir/bin" ]]; then
        PATH="$HOME/aws/$aws_dir/bin:$PATH"
    fi
done
