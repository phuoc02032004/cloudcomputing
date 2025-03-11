import json
import os
import subprocess
import boto3

def lambda_handler(event, context):
    health_check_url = os.getenv("HEALTH_CHECK_URL", "https://bpc-pos-admin-panel-api.nibies.space/health")

    try:
        response = subprocess.check_output(["curl", "-s", "-o", "/dev/null", "-w", "%{http_code}", health_check_url])
        if response == b'200':
            return {"statusCode": 200, "body": json.dumps({"status": "UP"})}
    except subprocess.CalledProcessError:
        pass

    ssm = boto3.client("ssm")
    command = ssm.send_command(
        DocumentName="AWS-RunShellScript",
        Parameters={"commands": ["terraform apply -auto-approve"]},
    )

    return {
        "statusCode": 500,
        "body": json.dumps({"message": "Instance down - Triggering Terraform!"})
    }