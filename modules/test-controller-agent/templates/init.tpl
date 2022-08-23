## template: jinja
#cloud-config

# Install packages
packages:
  - python3-pip
  - awscli
  - curl
  - zlib1g-dev
  - iproute2
  - linux-tools-common
  - linux-tools-generic
  - linux-tools-5.15.0-1008-aws
  - iperf
  - gdb
  - libpcap-dev

# Write files
write_files:
  - path: /etc/environment
    content: |
      AWS_REGION=${REGION}
      BINARIES_S3_BUCKET=${BINARIES_S3_BUCKET}
      OUTPUTS_S3_BUCKET=${OUTPUTS_S3_BUCKET}
    append: true
  - path: /root/update-networking.sh
    permissions: '0755'
    content: |
      #!/bin/sh

      # enable htcp congestion control algo
      modprobe tcp_htcp

      # allow testing with buffers up to 128MB
      sysctl -w net.core.rmem_max=134217728
      sysctl -w net.core.wmem_max=134217728

      # increase Linux autotuning TCP buffer limit to 64MB
      sysctl -w net.ipv4.tcp_rmem="4096 87380 67108864"
      sysctl -w net.ipv4.tcp_wmem="4096 65536 67108864"

      # increase the length of the processor input queue
      sysctl -w net.core.netdev_max_backlog=250000

      # recommended default congestion control is htcp
      sysctl -w net.ipv4.tcp_congestion_control=htcp

      # recommended for hosts with jumbo frames enabled
      sysctl -w net.ipv4.tcp_mtu_probing=1
  - path: /root/start-agent.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      rm -rf /root/agentdata
      mkdir /root/agentdata
      cd /root/agentdata
      EC2_INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id` /root/agent -host=${COORDINATOR_HOST} -port=${COORDINATOR_PORT}
  - path: /etc/systemd/system/cbdc-test-agent.service
    permissions: '0644'
    content: |
      [Unit]
      Description=CBDC Testing Agent
      After=network.target

      [Service]
      User=root
      Type=simple
      Restart=always
      RestartSec=3
      Environment="AWS_REGION=${REGION}"
      Environment="BINARIES_S3_BUCKET=${BINARIES_S3_BUCKET}"
      Environment="OUTPUTS_S3_BUCKET=${OUTPUTS_S3_BUCKET}"
      Environment="S3_INTERFACE_ENDPOINT=${S3_INTERFACE_ENDPOINT}"
      Environment="S3_INTERFACE_REGION=${S3_INTERFACE_REGION}"
      ExecStart=/root/start-agent.sh

      StandardOutput=append:/var/log/cbdc_agent_stdout.log
      StandardError=append:/var/log/cbdc_agent_stderr.log

      [Install]
      WantedBy=multi-user.target

# Run commands
runcmd:
  - curl "https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb" -o /tmp/amazon-cloudwatch-agent.deb
  - dpkg -i -E /tmp/amazon-cloudwatch-agent.deb
  - amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-Config.json -s
  - /root/update-networking.sh
  - aws --region ${REGION} --endpoint-url ${S3_INTERFACE_ENDPOINT} s3 cp s3://${BINARIES_S3_BUCKET}/${S3_BUCKET_PREFIX}/agent-latest /root/agent
  - aws --region ${REGION} --endpoint-url ${S3_INTERFACE_ENDPOINT} s3 cp s3://${BINARIES_S3_BUCKET}/${S3_BUCKET_PREFIX}/requirements.txt /root/requirements.txt
  - chmod +x /root/agent
  - pip3 install -r /root/requirements.txt
  - systemctl daemon-reload
  - systemctl start cbdc-test-agent.service
  - devname=`ip -o link show | awk '{ if ( $9 == "UP"){ print substr($2, 1, length($2)-1) } }'`; maxrx=`ethtool -g $devname | grep 'RX:' | head -1 | awk '{print $2}'`; currentrx=`ethtool -g $devname | grep 'RX:' | tail -1 | awk '{print $2}'`;currenttx=`ethtool -g $devname | grep 'TX:' | tail -1 | awk '{print $2}'`;maxtx=`ethtool -g $devname | grep 'TX:' | head -1 | awk '{print $2}'`; ethtool -G $devname rx $maxrx tx $currenttx
