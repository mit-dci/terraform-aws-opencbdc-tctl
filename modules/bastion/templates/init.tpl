#cloud-config
# vim: syntax=yaml
#
# This is the cloud-init configuration

# Install packages
packages:
  - awscli
  - nfs-common

# Download RDS cert bundle.
runcmd:
  - mkdir -p ${CERTS_MOUNT_PATH} ${TESTRUNS_MOUNT_PATH} ${BINARIES_MOUNT_PATH}
  - |
    echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${TESTRUNS_EFS_ID}.efs.${REGION}.amazonaws.com:/ \
    ${TESTRUNS_MOUNT_PATH} \
    nfs4 \
    ro,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - |
    echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${CERTS_EFS_ID}.efs.${REGION}.amazonaws.com:/ \
    ${CERTS_MOUNT_PATH} \
    nfs4 \
    rw,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - |
    echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${BINARIES_EFS_ID}.efs.${REGION}.amazonaws.com:/ \
    ${BINARIES_MOUNT_PATH} \
    nfs4 \
    nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" \
    >> /etc/fstab
  - mount -a -t nfs4
  - |
    aws \
    --region ${REGION} \
    ec2 associate-address \
    --instance-id "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" \
    --allocation-id ${EIP_ASSOCIATION_ID}
