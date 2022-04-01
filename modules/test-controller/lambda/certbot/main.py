import boto3
import certbot.main
import datetime
import os
# import raven
import subprocess

def read_and_delete_file(path):
  with open(path, 'r') as file:
    contents = file.read()
  os.remove(path)
  return contents

def provision_cert(email, domains):
  certbot.main.main([
    'certonly',                             # Obtain a cert but don't install it
    '-n',                                   # Run in non-interactive mode
    '--agree-tos',                          # Agree to the terms of service,
    '--email', email,                       # Email
    '--dns-route53',                        # Use dns challenge with route53
    '-d', domains,                          # Domains to provision certs for
    # Override directory paths so script doesn't have to be run as root
    '--config-dir', '/tmp/config-dir/',
    '--work-dir', '/tmp/work-dir/',
    '--logs-dir', '/tmp/logs-dir/',
  ])

  first_domain = domains.split(',')[0]
  path = '/tmp/config-dir/live/' + first_domain + '/'
  return {
    'certificate': read_and_delete_file(path + 'cert.pem'),
    'private_key': read_and_delete_file(path + 'privkey.pem'),
    'certificate_chain': read_and_delete_file(path + 'chain.pem'),
    'full_chain': read_and_delete_file(path + 'fullchain.pem')
  }

def should_provision(domains):
  existing_cert = find_existing_cert(domains)
  if existing_cert:
    now = datetime.datetime.now(datetime.timezone.utc)
    not_after = existing_cert['Certificate']['NotAfter']
    return (not_after - now).days <= 30
  else:
    return True

def find_existing_cert(domains):
  domains = frozenset(domains.split(','))

  client = boto3.client('acm')
  paginator = client.get_paginator('list_certificates')
  iterator = paginator.paginate(PaginationConfig={'MaxItems':1000})

  for page in iterator:
    for cert in page['CertificateSummaryList']:
      cert = client.describe_certificate(CertificateArn=cert['CertificateArn'])
      sans = frozenset(cert['Certificate']['SubjectAlternativeNames'])
      if sans.issubset(domains):
        return cert

  return None

def notify_via_sns(topic_arn, domains, certificate):
  process = subprocess.Popen(['openssl', 'x509', '-noout', '-text'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, encoding='utf8')
  stdout, stderr = process.communicate(certificate)

  client = boto3.client('sns')
  client.publish(TopicArn=topic_arn,
    Subject='Issued new LetsEncrypt certificate',
    Message='Issued new certificates for domains: ' + domains + '\n\n' + stdout,
  )

def copy_to_efs(cert, path):
  print(f'Overwriting certs in EFS volume mounted at {path}')
  certificate = open(os.path.join(path, "server.crt"), "w+")
  private_key = open(os.path.join(path, "server.key"), "w+")
  certificate.write(cert['full_chain'])
  private_key.write(cert['private_key'])
  os.chmod(os.path.join(path, "server.crt"), 0o600)
  os.chmod(os.path.join(path, "server.key"), 0o600)
  certificate.close()
  private_key.close()

def upload_cert_to_acm(cert, domains):
  existing_cert = find_existing_cert(domains)
  certificate_arn = existing_cert['Certificate']['CertificateArn'] if existing_cert else None

  client = boto3.client('acm')
  if certificate_arn:
    acm_response = client.import_certificate(
      CertificateArn=certificate_arn,
      Certificate=cert['certificate'],
      PrivateKey=cert['private_key'],
      CertificateChain=cert['certificate_chain']
    )
  else:
    acm_response = client.import_certificate(
      Certificate=cert['certificate'],
      PrivateKey=cert['private_key'],
      CertificateChain=cert['certificate_chain'],
      Tags=[
        {
            'Key': 'Name',
            'Value': str(domains)
        },
        {
            'Key': 'Owner',
            'Value': 'terraform'
        },
        {
            'Key': 'Managed_by',
            'Value': 'Certbot Lambda'
        }
      ]
    )

  return None if certificate_arn else acm_response['CertificateArn']

def handler(event, context):
  print("Starting cert update process...")
  try:
    domains = os.environ['LETSENCRYPT_DOMAINS']
    if should_provision(domains):
      cert = provision_cert(os.environ['LETSENCRYPT_EMAIL'], domains)
      upload_cert_to_acm(cert, domains)
      copy_to_efs(cert, os.environ['EFS_ACCESS_POINT_PATH'])
    #   notify_via_sns(os.environ['NOTIFICATION_SNS_ARN'], domains, cert['certificate'])
  except:
    # client = raven.Client(os.environ['SENTRY_DSN'], transport=raven.transport.http.HTTPTransport)
    # client.captureException()
    print("Nothing to do.")
    raise
