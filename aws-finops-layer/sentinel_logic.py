import boto3
import json

def audit_infrastructure_costs():
    ec2 = boto3.client('ec2')
    regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]
    
    violations = []

    for region in regions:
        ec2_region = boto3.client('ec2', region_name=region)
        instances = ec2_region.describe_instances()
        
        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                instance_type = instance['InstanceType']
                tags = {tag['Key']: tag['Value'] for tag in instance.get('Tags', [])}
                
                # Rule 1: Mandatory CostCenter Tag
                if 'CostCenter' not in tags:
                    violations.append({"ID": instance_id, "Region": region, "Issue": "Missing CostCenter Tag"})
                
                # Rule 2: Non-Standard Instance Types for Dev
                if not instance_type.startswith(('t2.', 't3.')):
                    violations.append({"ID": instance_id, "Type": instance_type, "Issue": "Expensive Instance Type"})

    return violations

if __name__ == "__main__":
    report = audit_infrastructure_costs()
    with open('finops_report.json', 'w') as f:
        json.dump(report, f, indent=4)
    print(f"FinOps Audit Completed. Found {len(report)} issues.")